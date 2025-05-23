import os
from wespeaker.bin.score import trials_cosine_score

def main():
    # Đường dẫn chính
    exp_dir = "exp/Whisper_PMFA_large_v2_vnceleb_mel_5s"
    eval_scp_path = os.path.join(exp_dir, "embeddings/private_test/xvector.scp")
    store_score_dir = os.path.join(exp_dir, "scores")
    trials = ["data/private_test/trials/prompts_sv.kaldi"]

    # Tạo thư mục lưu kết quả nếu chưa có
    os.makedirs(store_score_dir, exist_ok=True)

    print("Scoring cosine similarity for private test set ...")
    trials_cosine_score(
        eval_scp_path=eval_scp_path,
        store_dir=store_score_dir,
        mean_vec=None,
        trials=trials
    )

if __name__ == "__main__":
    main()