#!/bin/bash

exp_dir=exp/Whisper_PMFA_large_v2_vnceleb_mel_5s
model_path=exp/Whisper_PMFA_large_v2_vnceleb_mel_5s/models/final_model.pt
nj=1
gpus="[0]"
data_type="raw"
data=data
stage=private

. tools/parse_options.sh
set -e

if [ "$stage" == "private" ]; then
  data_name="private_test"
  batch_size=1
  num_workers=1
  nj=1
else
  echo "Usage: $0 --stage private [other options]"
  exit 1
fi

data_list_path="${data}/${data_name}/${data_type}.list"
data_scp_path="${data}/${data_name}/wav.scp"
wavs_num=$(wc -l < ${data_scp_path})

bash tools/extract_embedding.sh --exp_dir ${exp_dir} \
  --model_path $model_path \
  --data_type ${data_type} \
  --data_list ${data_list_path} \
  --wavs_num ${wavs_num} \
  --store_dir ${data_name} \
  --batch_size ${batch_size} \
  --num_workers ${num_workers} \
  --nj ${nj} \
  --gpus $gpus

echo "Embedding dir is (${exp_dir}/embeddings)."
