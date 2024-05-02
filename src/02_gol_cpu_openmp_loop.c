#include "common.h"
#include <omp.h> //Header file required for OpenMP functionality

void game_of_life(struct Options *opt, int *current_grid, int *next_grid, int n, int m){
    int neighbours;
    int n_i[8], n_j[8];

    /* Original for loop structure (i within j) is not optimal as it causes
    cache misses due to the element of next_grid[] being access was increasing
    by 1000 each time - changed nested loop structure to j within i instead */
    for(int i = 0; i < n; i++){

        /* Execute the inner for loop in parallel - arrays can be safely shared
        between threads as they will modify different elements of the next_grid
        array, and the current_grid does not get modified */
        #pragma omp parallel default(none) shared(current_grid, next_grid, m, n) private(neighbours, n_i, n_j, i)
        {
            /* Schedule the threads statically, since the amount of work does
            not vary between iterations */
            #pragma omp for schedule(static)
            for(int j = 0; j < m; j++){
                // count the number of neighbours, clockwise around the current cell.
                neighbours = 0;
                n_i[0] = i - 1; n_j[0] = j - 1;
                n_i[1] = i - 1; n_j[1] = j;
                n_i[2] = i - 1; n_j[2] = j + 1;
                n_i[3] = i;     n_j[3] = j + 1;
                n_i[4] = i + 1; n_j[4] = j + 1;
                n_i[5] = i + 1; n_j[5] = j;
                n_i[6] = i + 1; n_j[6] = j - 1;
                n_i[7] = i;     n_j[7] = j - 1;

                if(n_i[0] >= 0 && n_j[0] >= 0 && current_grid[n_i[0] * m + n_j[0]] == ALIVE) neighbours++;
                if(n_i[1] >= 0 && current_grid[n_i[1] * m + n_j[1]] == ALIVE) neighbours++;
                if(n_i[2] >= 0 && n_j[2] < m && current_grid[n_i[2] * m + n_j[2]] == ALIVE) neighbours++;
                if(n_j[3] < m && current_grid[n_i[3] * m + n_j[3]] == ALIVE) neighbours++;
                if(n_i[4] < n && n_j[4] < m && current_grid[n_i[4] * m + n_j[4]] == ALIVE) neighbours++;
                if(n_i[5] < n && current_grid[n_i[5] * m + n_j[5]] == ALIVE) neighbours++;
                if(n_i[6] < n && n_j[6] >= 0 && current_grid[n_i[6] * m + n_j[6]] == ALIVE) neighbours++;
                if(n_j[7] >= 0 && current_grid[n_i[7] * m + n_j[7]] == ALIVE) neighbours++;

                if(current_grid[i*m + j] == ALIVE && (neighbours == 2 || neighbours == 3)){
                    next_grid[i*m + j] = ALIVE;
                } else if(current_grid[i*m + j] == DEAD && neighbours == 3){
                    next_grid[i*m + j] = ALIVE;
                }else{
                    next_grid[i*m + j] = DEAD;
                }
            } //End for
        } //End parallel region
    }
}

void game_of_life_stats(struct Options *opt, int step, int *current_grid){
    unsigned long long num_in_state[NUMSTATES];
    int m = opt->m, n = opt->n;
    for(int i = 0; i < NUMSTATES; i++) num_in_state[i] = 0;
    
    /* Similar to the loops in game_of_life(), original for loop structure (i
    inside of j) is not optimal as it causes cache misses due to the element 
    of next_grid[] being access was increasing by 1000 each time - changed
    nested loop structure to j within i instead */
    for(int i = 0; i < n; i++){
        for(int j = 0; j < m; j++){
            num_in_state[current_grid[i*m + j]]++;
        }
    }
    double frac, ntot = opt->m*opt->n;
    FILE *fptr;
    if (step == 0) {
        fptr = fopen(opt->statsfile, "w");
    }
    else {
        fptr = fopen(opt->statsfile, "a");
    }
    fprintf(fptr, "step %d : ", step);
    for(int i = 0; i < NUMSTATES; i++) {
        frac = (double)num_in_state[i]/ntot;
        fprintf(fptr, "Frac in state %d = %f,\t", i, frac);
    }
    fprintf(fptr, " \n");
    fclose(fptr);
}



int main(int argc, char **argv)
{
    struct Options *opt = (struct Options *) malloc(sizeof(struct Options));
    getinput(argc, argv, opt);
    int n = opt->n, m = opt->m, nsteps = opt->nsteps;
    int *grid = (int *) malloc(sizeof(int) * n * m);
    int *updated_grid = (int *) malloc(sizeof(int) * n * m);
    if(!grid || !updated_grid){
        printf("Error while allocating memory.\n");
        return -1;
    }
    int current_step = 0;
    int *tmp = NULL;
    generate_IC(opt->iictype, grid, n, m);
    struct timeval start, steptime;
    start = init_time();
    while(current_step != nsteps){
        steptime = init_time();
        visualise(opt->ivisualisetype, current_step, grid, n, m);
        game_of_life_stats(opt, current_step, grid);
        game_of_life(opt, grid, updated_grid, n, m);
        // swap current and updated grid
        tmp = grid;
        grid = updated_grid;
        updated_grid = tmp;
        current_step++;
        get_elapsed_time(steptime);
    }
    printf("Finnished GOL\n");
    get_elapsed_time(start);
    free(grid);
    free(updated_grid);
    free(opt);
    return 0;
}
