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

exp_dir='' 
model_path=''
nj=4
gpus="[0]"
data_type="raw"  # shard/raw/feat
data=data

. tools/parse_options.sh
set -e

data_name="private_test"
data_list_path="${data}/${data_name}/${data_type}.list"
data_scp_path="${data}/${data_name}/wav.scp"
wavs_num=$(wc -l $data_scp_path | awk '{print $1}')
batch_size=16
num_workers=4

bash tools/extract_embedding.sh --exp_dir ${exp_dir} \
  --model_path $model_path \
  --data_type ${data_type} \
  --data_list ${data_list_path} \
  --wavs_num ${wavs_num} \
  --store_dir ${data_name} \
  --batch_size ${batch_size} \
  --num_workers ${num_workers} \
  --nj ${nj} \
  --gpus $gpus &
wait

echo "Embedding dir is (${exp_dir}/embeddings)."
