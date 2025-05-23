#!/bin/bash

set -e

# Lấy đường dẫn tuyệt đối tới thư mục chứa script
PROJECT_DIR="/root/Whisper_PMFA_Finetune"
export PYTHONPATH="${PROJECT_DIR}:${PYTHONPATH}"

awk '{print $0, "target"}' exp/Whisper_PMFA_large_v2_vnceleb_mel_5s/scores/prompts_sv.kaldi.score \
  > exp/Whisper_PMFA_large_v2_vnceleb_mel_5s/scores/prompts_sv.kaldi.score.labeled

exp_dir=${PROJECT_DIR}/exp/Whisper_PMFA_large_v2_vnceleb_mel_5s
cohort_set=vnceleb_train
top_n=300
score_norm_method=asnorm
trials_file=prompts_sv.kaldi
data=data

trial_score_file=${exp_dir}/scores/${trials_file}.score.labeled
score_norm_file=${exp_dir}/scores/${trials_file}.score.asnorm
cohort_emb_scp=${exp_dir}/embeddings/${cohort_set}/xvector.scp
eval_emb_scp=${exp_dir}/embeddings/private_test/xvector.scp

echo "Running AS-Norm for private_test..."

python ${PROJECT_DIR}/wespeaker/bin/score_norm.py \
  ${score_norm_method} \
  ${top_n} \
  ${trial_score_file} \
  ${score_norm_file} \
  ${cohort_emb_scp} \
  ${eval_emb_scp}