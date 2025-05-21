#!/bin/bash
set -e

# Example usage:
# bash local/score_private.sh --exp_dir exp/whisper_pmfa --data data/private_test --trials prompts_sv.kaldi

score_norm_method="asnorm"  # snorm/asnorm
cohort_set="vnceleb_train"
top_n=100
exp_dir=""
data=""
trials=""
stage=1
stop_stage=3

. tools/parse_options.sh
. path.sh

output_name=${cohort_set}_${score_norm_method}
[ "${score_norm_method}" == "asnorm" ] && output_name=${output_name}${top_n}

# Stage 1: Compute mean vector
if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
  echo "Stage 1: Compute mean xvector for $cohort_set"
  python tools/vector_mean.py \
    --spk2utt ${data}/${cohort_set}/spk2utt \
    --xvector_scp ${exp_dir}/embeddings/${cohort_set}/xvector.scp \
    --spk_xvector_ark ${exp_dir}/embeddings/${cohort_set}/spk_xvector.ark
fi

# Stage 2: Score with AS-Norm
if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
  echo "Stage 2: Scoring with $score_norm_method (top_n = $top_n)"
  for x in ${trials}; do
    python wespeaker/bin/score_norm.py \
      --score_norm_method $score_norm_method \
      --top_n $top_n \
      --trial_score_file $exp_dir/scores/${x}.score \
      --score_norm_file $exp_dir/scores/${output_name}_${x}.score \
      --cohort_emb_scp ${exp_dir}/embeddings/${cohort_set}/spk_xvector.scp \
      --eval_emb_scp ${exp_dir}/embeddings/private_test/xvector.scp \
      --mean_vec_path ${exp_dir}/embeddings/${cohort_set}/mean_vec.npy
  done
fi

# Stage 3: Compute metrics (if applicable)
if [ $stage -le 3 ] && [ $stop_stage -ge 3 ]; then
  echo "Stage 3: Compute metrics"
  for x in ${trials}; do
    scores_dir=${exp_dir}/scores
    python wespeaker/bin/compute_metrics.py \
      --p_target 0.05 \
      --c_fa 1 \
      --c_miss 1 \
      ${scores_dir}/${output_name}_${x}.score \
      2>&1 | tee -a ${scores_dir}/private_${score_norm_method}${top_n}_result

    python wespeaker/bin/compute_det.py \
      ${scores_dir}/${output_name}_${x}.score
  done
fi