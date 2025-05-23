input_path = "exp/Whisper_PMFA_large_v2_vnceleb_mel_5s/scores/prompts_sv.kaldi.score.asnorm"
output_path = "predictions.txt"

with open(input_path, 'r') as fin, open(output_path, 'w') as fout:
    for line in fin:
        parts = line.strip().split()
        if len(parts) >= 3:
            fout.write(parts[2] + '\n')