# Hướng dẫn Training Model AI Interview trên Kaggle

## Tổng quan

Tài liệu này hướng dẫn chi tiết cách train mô hình AI Interview Training System sử dụng Qwen/Qwen2.5-Coder-7B-Instruct trên Kaggle với GPU miễn phí.

## Yêu cầu hệ thống

### Kaggle Requirements
- **Tài khoản Kaggle**: Đã verify số điện thoại
- **GPU access**: Enable GPU trong Kaggle Notebook
- **Internet**: Cần kết nối để download model (khoảng 14GB)
- **Storage**: Tối thiểu 20GB available space

### Kinh nghiệm cần thiết
- Cơ bản về Python và Machine Learning
- Hiểu về fine-tuning và LoRA
- Kinh nghiệm với PyTorch/Transformers (khuyến khích)

## Bước 1: Chuẩn bị Dataset

### 1.1 Upload Dataset lên Kaggle

1. **Tạo Kaggle Dataset**:
   ```bash
   # Trên máy local
   pip install kaggle
   kaggle datasets init -p ./ai-interview-system/data
   ```

2. **Chỉnh sửa dataset-metadata.json**:
   ```json
   {
     "title": "AI Interview Training Dataset",
     "id": "yourusername/ai-interview-training-dataset",
     "licenses": [{"name": "CC0-1.0"}],
     "keywords": ["ai", "interview", "training", "nlp"],
     "collaborators": [],
     "data": []
   }
   ```

3. **Upload dataset**:
   ```bash
   kaggle datasets create -p ./ai-interview-system/data
   ```

### 1.2 Validate Dataset

Chạy validator để đảm bảo chất lượng data:
```python
python ai-interview-system/data/dataset_validator.py
```

Expected output:
```
✅ VALIDATION STATUS: PASSED
📊 DATASET STATISTICS:
  • Total Examples: 18
  • Total Questions: 51
  • Position Coverage: 15+ technical positions
```

## Bước 2: Setup Kaggle Notebook

### 2.1 Tạo mới Kaggle Notebook

1. Truy cập [Kaggle Kernels](https://www.kaggle.com/kernels)
2. Click "New Notebook"
3. Chọn "GPU P100" (miễn phí)
4. Import notebook từ file `ai-interview-system/kaggle/ai_interview_training.ipynb`

### 2.2 Add Dataset vào Notebook

1. Click "Add data" trong Kaggle Notebook
2. Search dataset tên "ai-interview-training-dataset"
3. Add vào notebook

### 2.3 Kiểm tra GPU

```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name()}")
```

Expected output:
```
CUDA available: True
GPU: Tesla P100-PCIE-16GB
```

## Bước 3: Cấu hình Training

### 3.1 Memory Management

**Quan trọng**: P100 có 16GB VRAM, cần optimize memory:

```python
# Quantization config
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_use_double_quant=True
)

# LoRA config
lora_config = LoraConfig(
    r=16,  # Rank - có thể giảm xuống 8 nếu hết memory
    lora_alpha=32,
    lora_dropout=0.1,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
)
```

### 3.2 Training Arguments

```python
training_args = TrainingArguments(
    output_dir="./ai-interview-model",
    per_device_train_batch_size=1,  # Bắt buộc = 1 cho P100
    gradient_accumulation_steps=8,   # Effective batch size = 8
    num_train_epochs=3,
    learning_rate=2e-4,
    fp16=True,                       # Quan trọng cho memory
    logging_steps=10,
    save_steps=100,
    evaluation_strategy="steps",
    eval_steps=50,
    load_best_model_at_end=True,
    dataloader_pin_memory=False,     # Tắt để tiết kiệm memory
    remove_unused_columns=False,
    report_to=None                   # Tắt wandb
)
```

## Bước 4: Training Process

### 4.1 Load Model và Tokenizer

```python
# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained(
    "Qwen/Qwen2.5-Coder-7B-Instruct", 
    trust_remote_code=True
)

# Load model với quantization
model = AutoModelForCausalLM.from_pretrained(
    "Qwen/Qwen2.5-Coder-7B-Instruct",
    quantization_config=bnb_config,
    device_map="auto",
    trust_remote_code=True,
    torch_dtype=torch.float16
)

# Apply LoRA
model = get_peft_model(model, lora_config)
```

### 4.2 Prepare Training Data

```python
def format_conversation(conversation):
    """Format theo Qwen chat template"""
    formatted_text = ""
    for message in conversation["messages"]:
        role = message["role"]
        content = message["content"]
        
        if role == "system":
            formatted_text += f"<|im_start|>system\n{content}<|im_end|>\n"
        elif role == "user":
            formatted_text += f"<|im_start|>user\n{content}<|im_end|>\n"
        elif role == "assistant":
            formatted_text += f"<|im_start|>assistant\n{content}<|im_end|>\n"
    
    return formatted_text
```

### 4.3 Start Training

```python
# Train model
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    data_collator=data_collator,
    tokenizer=tokenizer,
)

# Bắt đầu training
training_result = trainer.train()
```

**Thời gian dự kiến**: 2-3 giờ với P100

## Bước 5: Monitor Training

### 5.1 Theo dõi Loss

```python
# Check training logs
import matplotlib.pyplot as plt

# Plot training loss
logs = trainer.state.log_history
train_losses = [log['train_loss'] for log in logs if 'train_loss' in log]
plt.plot(train_losses)
plt.title('Training Loss')
plt.xlabel('Steps')
plt.ylabel('Loss')
plt.show()
```

### 5.2 Memory Usage

```python
# Monitor GPU memory
print(f"Memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
print(f"Memory cached: {torch.cuda.memory_reserved() / 1024**3:.2f} GB")
```

**Lưu ý**: Nếu bị OOM (Out of Memory):
1. Giảm `per_device_train_batch_size` xuống 1
2. Tăng `gradient_accumulation_steps` 
3. Giảm `max_length` trong tokenization
4. Giảm LoRA rank từ 16 xuống 8

## Bước 6: Evaluation và Testing

### 6.1 Evaluate Model

```python
# Run evaluation
eval_results = trainer.evaluate()
print("Evaluation Results:")
for key, value in eval_results.items():
    print(f"  {key}: {value:.4f}")
```

### 6.2 Test Generation

```python
def test_question_generation(cv_text, job_desc, position, level):
    """Test sinh câu hỏi phỏng vấn"""
    
    system_prompt = f"""
You are an expert technical interviewer. Generate relevant questions based on CV and job requirements.

Position: {position}
Level: {level}
Job Requirements: {job_desc}
Candidate CV: {cv_text}
"""
    
    user_prompt = "Generate a technical interview question for this candidate."
    
    # Format input
    formatted_input = f"<|im_start|>system\n{system_prompt}<|im_end|>\n<|im_start|>user\n{user_prompt}<|im_end|>\n<|im_start|>assistant\n"
    
    # Tokenize và generate
    inputs = tokenizer(formatted_input, return_tensors="pt", truncation=True, max_length=1024)
    inputs = {k: v.to(model.device) for k, v in inputs.items()}
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=200,
            temperature=0.7,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Extract assistant response
    assistant_start = response.find("<|im_start|>assistant\n") + len("<|im_start|>assistant\n")
    generated_question = response[assistant_start:].split("<|im_end|>")[0].strip()
    
    return generated_question

# Test với sample data
test_question = test_question_generation(
    cv_text="Senior Python Developer with 5 years experience in Django and PostgreSQL",
    job_desc="Backend Developer role requiring Python, Django, PostgreSQL",
    position="Senior Backend Developer",
    level="senior"
)

print(f"Generated question: {test_question}")
```

## Bước 7: Save và Export Model

### 7.1 Save LoRA Adapter

```python
# Save LoRA weights
model.save_pretrained("./ai-interview-model")
tokenizer.save_pretrained("./ai-interview-model")

print("✅ Model saved successfully!")
```

### 7.2 Create Deployment Package

```python
import zipfile
import os

# Tạo zip file để download
with zipfile.ZipFile("ai_interview_model_deployment.zip", "w", zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk("./ai-interview-model"):
        for file in files:
            file_path = os.path.join(root, file)
            arcname = os.path.relpath(file_path, "./ai-interview-model")
            zipf.write(file_path, arcname)

print("✅ Deployment package created!")
```

### 7.3 Model Info

```python
# Tạo file thông tin model
model_info = {
    "base_model": "Qwen/Qwen2.5-Coder-7B-Instruct",
    "training_date": datetime.now().isoformat(),
    "lora_config": {
        "r": lora_config.r,
        "alpha": lora_config.lora_alpha,
        "dropout": lora_config.lora_dropout
    },
    "training_results": {
        "final_loss": training_result.training_loss,
        "epochs": training_args.num_train_epochs
    },
    "dataset_info": {
        "total_examples": len(train_dataset),
        "positions_covered": 15
    }
}

with open("model_info.json", "w") as f:
    json.dump(model_info, f, indent=2)
```

## Bước 8: Download Model

### 8.1 Download từ Kaggle

1. **Output tab**: Click vào "Output" tab trong notebook
2. **Download**: Download file `ai_interview_model_deployment.zip`
3. **Model info**: Download `model_info.json` để có thông tin chi tiết

### 8.2 Verify Download

```bash
# Giải nén và kiểm tra
unzip ai_interview_model_deployment.zip
ls -la ai-interview-model/

# Expected files:
# - adapter_config.json
# - adapter_model.bin
# - tokenizer.json
# - tokenizer_config.json
# - vocab.json
```

## Troubleshooting

### Common Issues

1. **Out of Memory (OOM)**:
   ```python
   # Solution: Reduce batch size và increase gradient accumulation
   training_args.per_device_train_batch_size = 1
   training_args.gradient_accumulation_steps = 16
   ```

2. **Slow Training**:
   ```python
   # Check GPU utilization
   !nvidia-smi
   
   # Ensure using fp16
   training_args.fp16 = True
   ```

3. **Model Download lỗi**:
   ```python
   # Set proxy nếu cần
   import os
   os.environ['HF_HUB_DISABLE_PROGRESS_BARS'] = '1'
   ```

4. **Tokenizer errors**:
   ```python
   # Add special tokens
   if tokenizer.pad_token is None:
       tokenizer.pad_token = tokenizer.eos_token
   ```

### Memory Optimization Tips

1. **Gradient Checkpointing**:
   ```python
   model.gradient_checkpointing_enable()
   ```

2. **Clear Cache thường xuyên**:
   ```python
   torch.cuda.empty_cache()
   gc.collect()
   ```

3. **Reduce sequence length**:
   ```python
   # Trong tokenize_function
   max_length=512  # thay vì 1024
   ```

## Performance Expectations

### Training Time
- **P100 (16GB)**: 2-3 giờ cho 3 epochs
- **T4 (16GB)**: 3-4 giờ cho 3 epochs  
- **Data size**: 18 examples với 51 questions

### Memory Usage
- **Model loading**: ~7GB
- **Training**: ~14GB peak
- **LoRA adapters**: ~100MB

### Expected Results
- **Training loss**: Giảm từ ~3.0 xuống ~1.5
- **Eval loss**: ~1.8-2.2
- **Generation quality**: Câu hỏi relevant và technical

## Next Steps

Sau khi training xong:

1. **Deploy model**: Sử dụng FastAPI service
2. **Test integration**: Tích hợp với landing page
3. **Monitor performance**: Theo dõi chất lượng câu hỏi
4. **Iterate**: Cải thiện dataset và retrain

## Support

Nếu gặp vấn đề:

1. Check Kaggle notebook logs
2. Monitor GPU memory usage
3. Reduce batch size nếu cần
4. Post issue với detailed error logs

**Chúc bạn training thành công! 🚀**