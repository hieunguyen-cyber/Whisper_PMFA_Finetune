#!/bin/bash

# Copyright (c) 2022 Hongji Wang (jijijiang77@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

stage=-1
stop_stage=-1
data=data

. tools/parse_options.sh || exit 1

data=`realpath ${data}`
download_dir=${data}/download_data
rawdata_dir=${data}/raw_data

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
  echo "Download musan.tar.gz, rirs_noises.zip, vnceleb.zip, and private_test.zip."
  echo "This may take a long time. Thus we recommand you to download all archives above in your own way first."

  ./local/download_data.sh --download_dir ${download_dir}
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
  echo "Decompress all archives ..."
  echo "This could take some time ..."

  for archive in musan.tar.gz rirs_noises.zip vnceleb.zip private_test.zip; do
    [ ! -f ${download_dir}/$archive ] && echo "Archive $archive not exists !!!" && exit 1
  done
  [ ! -d ${rawdata_dir} ] && mkdir -p ${rawdata_dir}

  if [ ! -d ${rawdata_dir}/musan ]; then
    tar -xzvf ${download_dir}/musan.tar.gz -C ${rawdata_dir}
  fi

  if [ ! -d ${rawdata_dir}/RIRS_NOISES ]; then
    unzip ${download_dir}/rirs_noises.zip -d ${rawdata_dir}
  fi

  if [ ! -d ${rawdata_dir}/vnceleb ]; then
    mkdir -p ${rawdata_dir}/vnceleb
    unzip ${download_dir}/vnceleb.zip -d ${rawdata_dir}/vnceleb # VN Celeb vào hết 1 file
  fi

  if [ ! -d ${rawdata_dir}/private_test ]; then
    mkdir -p ${rawdata_dir}/private_test
    unzip ${download_dir}/private_test.zip -d ${rawdata_dir}/private_test # Private Test vào hết 1 file
  fi

  echo "Decompress success !!!"
fi
###############=====================#######################=====================#######################=====================#######################=====================#######################

if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
  echo "Prepare wav.scp for each dataset ..."
  export LC_ALL=C # kaldi config

  mkdir -p ${data}/musan ${data}/rirs 
  # musan
  find ${rawdata_dir}/musan -name "*.wav" | awk -F"/" '{print $(NF-2)"/"$(NF-1)"/"$NF,$0}' >${data}/musan/wav.scp
  # rirs
  find ${rawdata_dir}/RIRS_NOISES/simulated_rirs -name "*.wav" | awk -F"/" '{print $(NF-2)"/"$(NF-1)"/"$NF,$0}' >${data}/rirs/wav.scp
###############=====================#######################
  # vnceleb train
  echo "Prepare vnceleb_train ..."
  mkdir -p ${data}/vnceleb_train
  cat ${rawdata_dir}/vnceleb/vietnam-celeb-t.txt | \
    sed 's/\r$//' | \
    tr -s '\t' ' ' | tr -s ' ' | \
    grep -v '^$' | \
    while read spk wav; do
      utt_id="${spk}/${wav}"
      path="${rawdata_dir}/vnceleb/full-dataset/data/${utt_id}"
      if [ -f "$path" ]; then
        echo "FOUND: $path"
        echo "$utt_id $path" >> ${data}/vnceleb_train/wav.scp
        echo "$utt_id $spk" >> ${data}/vnceleb_train/utt2spk
      else
        echo "MISSING: $path"
      fi
    done
  ./tools/utt2spk_to_spk2utt.pl ${data}/vnceleb_train/utt2spk > ${data}/vnceleb_train/spk2utt
###############=====================#######################
  # vnceleb train
  echo "Prepare vnceleb_train ..."
  mkdir -p ${data}/vnceleb_test
  cat ${rawdata_dir}/vnceleb/vietnam-celeb-t.txt | \
    sed 's/\r$//' | \
    tr -s '\t' ' ' | tr -s ' ' | \
    grep -v '^$' | \
    while read spk wav; do
      utt_id="${spk}/${wav}"
      path="${rawdata_dir}/vnceleb/full-dataset/data/${utt_id}"
      if [ -f "$path" ]; then
        echo "FOUND: $path"
        echo "$utt_id $path" >> ${data}/vnceleb_test/wav.scp
        echo "$utt_id $spk" >> ${data}/vnceleb_test/utt2spk
      else
        echo "MISSING: $path"
      fi
    done
  ./tools/utt2spk_to_spk2utt.pl ${data}/vnceleb_test/utt2spk > ${data}/vnceleb_test/spk2utt
###############=====================#######################
  mkdir -p ${data}/vnceleb_test/trials
  # Kiểm tra tồn tại cặp audio rồi mới ghi vnceleb-e.kaldi
  > ${data}/vnceleb_test/trials/vnceleb-e.kaldi
  while read label utt1 utt2; do
    path1="${rawdata_dir}/vnceleb/full-dataset/data/${utt1}"
    path2="${rawdata_dir}/vnceleb/full-dataset/data/${utt2}"
    if [ -f "$path1" ] && [ -f "$path2" ]; then
      if [ "$label" = "1" ]; then
        lbl="target"
      elif [ "$label" = "0" ]; then
        lbl="nontarget"
      else
        echo "SKIP (label error): $label $utt1 $utt2" >&2
        continue
      fi
      echo "FOUND: $path1 $path2"
      echo "$utt1 $utt2 $lbl" >> ${data}/vnceleb_test/trials/vnceleb-e.kaldi
    else
      echo "MISSING: $utt1 or $utt2" >&2
    fi
  done < <(cat ${rawdata_dir}/vnceleb/vietnam-celeb-e.txt | sed 's/\r$//' | tr -s '\t' ' ')
###############=====================#######################
  # Kiểm tra tồn tại cặp audio rồi mới ghi vnceleb-h.kaldi
  > ${data}/vnceleb_test/trials/vnceleb-h.kaldi
  while read label utt1 utt2; do
    path1="${rawdata_dir}/vnceleb/full-dataset/data/${utt1}"
    path2="${rawdata_dir}/vnceleb/full-dataset/data/${utt2}"
    if [ -f "$path1" ] && [ -f "$path2" ]; then
      if [ "$label" = "1" ]; then
        lbl="target"
      elif [ "$label" = "0" ]; then
        lbl="nontarget"
      else
        echo "SKIP (label error): $label $utt1 $utt2" >&2
        continue
      fi
      echo "FOUND: $path1 $path2"
      echo "$utt1 $utt2 $lbl" >> ${data}/vnceleb_test/trials/vnceleb-h.kaldi
    else
      echo "MISSING: $utt1 or $utt2" >&2
    fi
  done < <(cat ${rawdata_dir}/vnceleb/vietnam-celeb-h.txt | sed 's/\r$//' | tr -s '\t' ' ')
###############=====================#######################=====================#######################=====================#######################=====================#######################
  # private_test_sv
  echo "Prepare private_test ..."
  mkdir -p ${data}/private_test
  find ${rawdata_dir}/private_test/private-test-data-sv -name "*.wav" | \
    awk -F"/" '{print $NF, $0}' | sort > ${data}/private_test/wav.scp
  awk '{print $1,$1}' ${data}/private_test/wav.scp > ${data}/private_test/utt2spk
  ./tools/utt2spk_to_spk2utt.pl ${data}/private_test/utt2spk > ${data}/private_test/spk2utt

  echo "Prepare private_test trials ..."
  mkdir -p ${data}/private_test/trials
  awk -F"," '{print $1, $2}' ${rawdata_dir}/private_test/prompts_sv.csv > ${data}/private_test/trials/prompts_sv.kaldi

  echo "Success !!!"
fi
