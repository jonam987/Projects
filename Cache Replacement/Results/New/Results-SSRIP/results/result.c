#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

#define BUFFER_SIZE 1024
#define PREFIX "sim_IPC"
#define MAX_LINES 1000

void extractLinesWithPrefix(const char *sourceFile, char lines[MAX_LINES][BUFFER_SIZE], int *lineCount) {
    FILE *src = fopen(sourceFile, "r");
    if (src == NULL) {
        perror("Error opening source file");
        return;
    }

    char buffer[BUFFER_SIZE];
    while (fgets(buffer, sizeof(buffer), src) != NULL) {
        if (strncmp(buffer, PREFIX, strlen(PREFIX)) == 0) {
            if (*lineCount < MAX_LINES) {
                snprintf(lines[*lineCount], BUFFER_SIZE, "From file %s: %s", sourceFile, buffer);
                (*lineCount)++;
            } else {
                fprintf(stderr, "Exceeded maximum line storage capacity.\n");
                break;
            }
        }
    }

    fclose(src);
}

void processDirectory(const char *dirPath, char lines[MAX_LINES][BUFFER_SIZE], int *lineCount) {
    DIR *dir = opendir(dirPath);
    if (dir == NULL) {
        perror("Error opening directory");
        exit(EXIT_FAILURE);
    }

    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_REG) { // Regular file
            const char *filename = entry->d_name;
            const char *ext = strrchr(filename, '.');
            if (ext && strcmp(ext, ".out") == 0) {
                char filepath[BUFFER_SIZE];
                snprintf(filepath, sizeof(filepath), "%s/%s", dirPath, filename);
                extractLinesWithPrefix(filepath, lines, lineCount);
            }
        }
    }

    closedir(dir);
}

int compareLines(const void *a, const void *b) {
    return strcmp(*(const char **)a, *(const char **)b);
}

void writeSortedLinesToFile(const char *destFile, char lines[MAX_LINES][BUFFER_SIZE], int lineCount) {
    FILE *dst = fopen(destFile, "w");
    if (dst == NULL) {
        perror("Error opening destination file");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < lineCount; i++) {
        fputs(lines[i], dst);
    }

    fclose(dst);
}

int main() {
    const char *directory = ".";
    const char *destFile = "combined_output.txt";

    char lines[MAX_LINES][BUFFER_SIZE];
    int lineCount = 0;

    processDirectory(directory, lines, &lineCount);

    qsort(lines, lineCount, sizeof(lines[0]), compareLines);

    writeSortedLinesToFile(destFile, lines, lineCount);

    printf("Lines from .out files starting with '%s' have been extracted, sorted, and written to %s\n", PREFIX, destFile);

    return 0;
}
