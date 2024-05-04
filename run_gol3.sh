#!/bin/bash -l

#SBATCH --job-name=gol-test-ttutungis 
#SBATCH --ntasks=16
#SBATCH --reservation=CurtinHPCcourse
#SBATCH --time=02:00:00

cd /scratch/courses0100/ttutungis/openmp_assignment
mkdir run/
mkdir run/original_o2
mkdir run/original_o3
mkdir run/original_cray_o2
mkdir run/original_cray_o3
mkdir run/gcc_o2
mkdir run/gcc_o3
mkdir run/cray_o2
mkdir run/cray_o3

module load PrgEnv-cray

cd ../gol1
make clean
make COMPILERTYPE=CRAY PROFILER=ON cpu_serial_cc 
cd ../openmp_assignment/

for i in 1000 10000
do
    ../gol1/bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > run/original_cray_o2/log_original_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/original_cray_o2/stats_original_${i}x${i}.txt
    gprof -lbp ../gol1/bin/01_gol_cpu_serial ./gmon.out > run/original_cray_o2/analysis_original_${i}x${i}.txt

done

cd ../gol1
make clean
make COMPILERTYPE=CRAY PROFILER=ON OPTLEVEL=3 cpu_serial_cc 
cd ../openmp_assignment/
for i in 1000 10000
do
    ../gol1/bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > run/original_cray_o3/log_original_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/original_cray_o3/stats_original_${i}x${i}.txt
    gprof -lbp ../gol1/bin/01_gol_cpu_serial ./gmon.out > run/original_cray_o3/analysis_original_${i}x${i}.txt

done

make clean
make COMPILERTYPE=CRAY PROFILER=ON cpu_serial_cc cpu_openmp_loop_cc
for i in 10 50 100 250 500 1000 2500 5000 10000
do
    ./bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > ./run/cray_o2/log_serial_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/cray_o2/stats_serial_${i}x${i}.txt
    gprof -lbp ./bin/01_gol_cpu_serial gmon.out > ./run/cray_o2/analysis_serial_${i}x${i}.txt

    for j in 1 2 3 4 5 6 7 8 10 12 14 16
    do
        OMP_NUM_THREADS=${j} ./bin/02_gol_cpu_openmp_loop ${i} ${i} 100 0 -1 > ./run/cray_o2/log_loop_${i}x${i}_${j}threads.txt
        mv ./GOL-stats.txt ./run/cray_o2/stats_loop_${i}x${i}_${j}threads.txt
        OMP_NUM_THREADS=${j} gprof -lbp ./bin/02_gol_cpu_openmp_loop gmon.out > ./run/cray_o2/analysis_loop_${i}x${i}_${j}threads.txt
    done
done

make clean
make COMPILERTYPE=CRAY PROFILER=ON OPTLEVEL=3 cpu_serial_cc cpu_openmp_loop_cc
for i in 10 50 100 250 500 1000 2500 5000 10000
do
    ./bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > ./run/cray_o3/log_serial_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/cray_o3/stats_serial_${i}x${i}.txt
    gprof -lbp ./bin/01_gol_cpu_serial gmon.out > ./run/cray_o3/analysis_serial_${i}x${i}.txt

    for j in 1 2 3 4 5 6 7 8 10 12 14 16
    do
        OMP_NUM_THREADS=${j} ./bin/02_gol_cpu_openmp_loop ${i} ${i} 100 0 -1 > ./run/cray_o3/log_loop_${i}x${i}_${j}threads.txt
        mv ./GOL-stats.txt ./run/cray_o3/stats_loop_${i}x${i}_${j}threads.txt
        OMP_NUM_THREADS=${j} gprof -lbp ./bin/02_gol_cpu_openmp_loop gmon.out > ./run/cray_o3/analysis_loop_${i}x${i}_${j}threads.txt
    done
done

module load PrgEnv-gnu

cd ../gol1
make clean
make COMPILERTYPE=CRAY PROFILER=ON cpu_serial_cc 
cd ../openmp_assignment/
for i in 1000 10000
do
    ../gol1/bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > run/original_o2/log_original_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/original_o2/stats_original_${i}x${i}.txt
    gprof -lbp ../gol1/bin/01_gol_cpu_serial ./gmon.out > run/original_o2/analysis_original_${i}x${i}.txt

done

cd ../gol1
make clean
make COMPILERTYPE=CRAY PROFILER=ON OPTLEVEL=3 cpu_serial_cc 
cd ../openmp_assignment/
for i in 1000 10000
do
    ../gol1/bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > run/original_o3/log_original_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/original_o3/stats_original_${i}x${i}.txt
    gprof -lbp ../gol1/bin/01_gol_cpu_serial ./gmon.out > run/original_o3/analysis_original_${i}x${i}.txt

done

make clean
make COMPILERTYPE=CRAY PROFILER=ON cpu_serial_cc cpu_openmp_loop_cc
for i in 10 50 100 250 500 1000 2500 5000 10000
do
    ./bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > ./run/gcc_o2/log_serial_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/gcc_o2/stats_serial_${i}x${i}.txt
    gprof -lbp ./bin/01_gol_cpu_serial gmon.out > ./run/gcc_o2/analysis_serial_${i}x${i}.txt

    for j in 1 2 3 4 5 6 7 8 10 12 14 16
    do
        OMP_NUM_THREADS=${j} ./bin/02_gol_cpu_openmp_loop ${i} ${i} 100 0 -1 > ./run/gcc_o2/log_loop_${i}x${i}_${j}threads.txt
        mv ./GOL-stats.txt ./run/gcc_o2/stats_loop_${i}x${i}_${j}threads.txt
        OMP_NUM_THREADS=${j} gprof -lbp ./bin/02_gol_cpu_openmp_loop gmon.out > ./run/gcc_o2/analysis_loop_${i}x${i}_${j}threads.txt
    done
done

make clean
make COMPILERTYPE=CRAY PROFILER=ON OPTLEVEL=3 cpu_serial_cc cpu_openmp_loop_cc
for i in 10 50 100 250 500 1000 2500 5000 10000
do
    ./bin/01_gol_cpu_serial ${i} ${i} 100 0 -1 > ./run/gcc_o3/log_serial_${i}x${i}.txt
    mv ./GOL-stats.txt ./run/gcc_o3/stats_serial_${i}x${i}.txt
    gprof -lbp ./bin/01_gol_cpu_serial gmon.out > ./run/gcc_o3/analysis_serial_${i}x${i}.txt

    for j in 1 2 3 4 5 6 7 8 10 12 14 16
    do
        OMP_NUM_THREADS=${j} ./bin/02_gol_cpu_openmp_loop ${i} ${i} 100 0 -1 > ./run/gcc_o3/log_loop_${i}x${i}_${j}threads.txt
        mv ./GOL-stats.txt ./run/gcc_o3/stats_loop_${i}x${i}_${j}threads.txt
        OMP_NUM_THREADS=${j} gprof -lbp ./bin/02_gol_cpu_openmp_loop gmon.out > ./run/gcc_o3/analysis_loop_${i}x${i}_${j}threads.txt
    done
done

