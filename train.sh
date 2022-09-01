#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:a100:4
#SBATCH --cpus-per-task=8
#SBATCH --mem=492GB
#SBATCH --time=48:00:00
#SBATCH --array=0
#SBATCH --job-name=train_gpt
#SBATCH --output=train_gpt_%A_%a.out

### change WORLD_SIZE as gpus/node * num_nodes
export MASTER_ADDR=$(hostname -s)
export MASTER_PORT=$(shuf -i 10000-65500 -n 1)
export WORLD_SIZE=4

module purge
module load cuda/11.3.1

LR=0.0001
OPTIMIZER='Adam'

srun python -u /scratch/eo41/visual-recognition-memory/train.py \
	--save_dir '/scratch/eo41/visual-recognition-memory/gpt_pretrained_models' \
	--batch_size 24 \
	--n_layer 48 \
	--n_head 25 \
	--n_emb 1600 \
	--num_workers 4 \
	--print_freq 5000 \
	--optimizer $OPTIMIZER \
	--lr $LR \
	--seed $SLURM_ARRAY_TASK_ID \
	--resume ''

echo "Done"
