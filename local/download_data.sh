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

download_dir=data/download_data

. tools/parse_options.sh || exit 1

[ ! -d ${download_dir} ] && mkdir -p ${download_dir}

if [ ! -f ${download_dir}/musan.tar.gz ]; then
  echo "Downloading musan.tar.gz ..."
  wget --no-check-certificate https://openslr.elda.org/resources/17/musan.tar.gz -P ${download_dir}
  md5=$(md5sum ${download_dir}/musan.tar.gz | awk '{print $1}')
  [ $md5 != "0c472d4fc0c5141eca47ad1ffeb2a7df" ] && echo "Wrong md5sum of musan.tar.gz" && exit 1
fi

if [ ! -f ${download_dir}/rirs_noises.zip ]; then
  echo "Downloading rirs_noises.zip ..."
  wget --no-check-certificate https://us.openslr.org/resources/28/rirs_noises.zip -P ${download_dir}
  md5=$(md5sum ${download_dir}/rirs_noises.zip | awk '{print $1}')
  [ $md5 != "e6f48e257286e05de56413b4779d8ffb" ] && echo "Wrong md5sum of rirs_noises.zip" && exit 1
fi

if [ ! -f ${download_dir}/vnceleb.zip ]; then # VNCeleb 
  echo "Downloading vnceleb.zip ..."
  wget --header='Host: storage.googleapis.com' --header='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='Accept-Language: vi-VN,vi;q=0.9,fr-FR;q=0.8,fr;q=0.7,en-US;q=0.6,en;q=0.5' --header='Referer: https://www.kaggle.com/' 'https://storage.googleapis.com/kaggle-data-sets/6096635/9920101/bundle/archive.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20250521%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20250521T021537Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=80af8ea100c8119a1467432db2c7a6e553bd5272e06088608db41b30b8a8597a95cd23a0e63aa82dd00e52ae7576de61d136a53a0b577e2d0f6bbec2108daf53cea00527197cd079db776b859ff710a20ae888175c5143c7a54fd0bcdaad69348a6418fff220b9fe1387149cc6cfaf0c4b9496217408ca66dd56dbd4f86affe24cec8ba8c0a866ea78b78ae7f9f3d6f5c6acb03140b0b166e43400674381b844b1bfead02a0a4b6f9d7207e9efe4471cc13f8cf74ff69c568eb3baa00093dd0492cb11ee5d0511028c46056a8d5eb6dd39227e2bb3d0003d014a16702261ac9afb052b7fab583a04fa4fc1d3771f0c7c5c3185fe478b970213f71bf15cd6053c' -c -O ${download_dir}/vnceleb.zip
  md5=$(md5sum ${download_dir}/vnceleb.zip | awk '{print $1}')
  [ $md5 != "f99a41675dff7d0e66d0cd6a23c83769" ] && echo "Wrong md5sum of train.zip" && exit 1
fi

if [ ! -f ${download_dir}/private_test.zip ]; then # Private test
  echo "Downloading private_test.zip ..."
  wget --header='Host: storage.googleapis.com' --header='User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header='Accept-Language: vi-VN,vi;q=0.9,fr-FR;q=0.8,fr;q=0.7,en-US;q=0.6,en;q=0.5' --header='Referer: https://www.kaggle.com/' 'https://storage.googleapis.com/kaggle-data-sets/7392791/11775373/bundle/archive.zip?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Credential=gcp-kaggle-com%40kaggle-161607.iam.gserviceaccount.com%2F20250521%2Fauto%2Fstorage%2Fgoog4_request&X-Goog-Date=20250521T023139Z&X-Goog-Expires=259200&X-Goog-SignedHeaders=host&X-Goog-Signature=6db28b9248094cfe5591219318c2221988a891775bd4712cf8ef5e302b2f6d9c3eb748027c37de16f008f7d4a16ba2aafc5e6629835c23e13a679f788430962af49301ca5d0714aba14970528ea70dab09c1a0b1559c6d6e429398362e1f247c46629175404a783299c7ac127c6ef175e3d7a4b12c4c98dd81a5b8dbc51cb2aa4b4277d03a85818f187107163dd5bdebf62266961dbd43b582d3cf256829d6502a9e23c15a25aeb6daa2b8f8152e6ccdc0b1fa6ec9a84dc2b43f797930a04e430013e7debc1b5f5a012eed4a4b149d644dd8bb650c57e79e409ba69ee926ffa1b536310dde3d3e9f8a177fcf5bd53b8d33b680eabd50907e668af24f7952dee2' -c -O ${download_dir}/private_test.zip
  md5=$(md5sum ${download_dir}/private_test.zip | awk '{print $1}')
  [ $md5 != "f99a41675dff7d0e66d0cd6a23c83769" ] && echo "Wrong md5sum of private_test.zip" && exit 1
fi

echo "Download success !!!"
