#!/bin/bash

# Copyright (c) 2022 Chengdong Liang (liangchengdong@mail.nwpu.edu.cn)
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

exp_dir=
trials="prompts_sv.kaldi"
data=data

. tools/parse_options.sh
. path.sh

echo "Apply cosine scoring ..."
mkdir -p ${exp_dir}/scores
trials_dir=${data}/private_test/trials
echo $trials
python wespeaker/bin/score.py \
    --exp_dir ${exp_dir} \
    --eval_scp_path ${exp_dir}/embeddings/private_test/xvector.scp \
    --cal_mean False \
    ${trials_dir}/${trials}

