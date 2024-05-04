#!/bin/bash -l

#SBATCH --job-name=gol-test-ttutungis 
#SBATCH --ntasks=16
#SBATCH --reservation=CurtinHPCcourse
#SBATCH --time=00:30:00

cd /scratch/courses0100/ttutungis/openmp_assignment

for i in 10 50 100 250 500 1000 2500 5000 7500 10000
do
    ./bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > serial_${i}x${i}_100rounds.txt
    mv ./GOL-stats.txt ./stats_serial_${i}x${i}_100rounds.txt
    gprof -lbp ./bin/01_gol_cpu_serial gmon.out > ./analysis_serial_${i}x${i}_100rounds.txt

    for j in 1 2 3 4 5 6 7 8 10 12 14 16
    do
        OMP_NUM_THREADS=${j} ./bin/02_gol_cpu_openmp_loop ${i} ${i} 100 0 -1 > loop_${i}x${i}_100rounds_${j}threads.txt
        mv ./GOL-stats.txt ./stats_loop_${i}x${i}_100rounds_${j}threads.txt
        OMP_NUM_THREADS=${j} gprof -lbp ./bin/02_gol_cpu_openmp_loop gmon.out > ./analysis_loop_${i}x${i}_100rounds_${j}threads.txt
    done
done

mkdir batch/
mv ./*.txt batch/
