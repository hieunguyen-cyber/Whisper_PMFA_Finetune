#!/bin/bash

exp_dir=''
model_path=''
nj=4
gpus="[0]"
data_type="raw"
data=data
stage=train

. tools/parse_options.sh
set -e

if [ "$stage" == "train" ]; then
  data_name="vnceleb_train"
  batch_size=16
  num_workers=4
  nj=$nj
elif [ "$stage" == "test" ]; then
  data_name="vnceleb_test"
  batch_size=1
  num_workers=1
  nj=1
else
  echo "Usage: $0 --stage train|test [other options]"
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