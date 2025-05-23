import os

def check_scp_offsets(scp_path):
    with open(scp_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            utt, ark_path_offset = line.split(maxsplit=1)
            if ':' not in ark_path_offset:
                print(f"[WARN] Line malformed (no offset): {line}")
                continue
            ark_path, offset_str = ark_path_offset.rsplit(':', 1)
            try:
                offset = int(offset_str)
            except ValueError:
                print(f"[WARN] Invalid offset '{offset_str}' in line: {line}")
                continue

            if not os.path.isfile(ark_path):
                print(f"[WARN] Ark file does not exist: {ark_path}")
                continue
            filesize = os.path.getsize(ark_path)
            if offset >= filesize:
                print(f"[ERROR] Offset {offset} out of range for file {ark_path} (size {filesize}) at utt {utt}")

# Thay đường dẫn sau bằng đường dẫn thực tế của file scp train
train_scp = 'exp/Whisper_PMFA_large_v2_vnceleb_mel_5s/embeddings/vnceleb_test/xvector.scp'
check_scp_offsets(train_scp)