#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

#define BUFFER_SIZE 1024
#define PREFIX "sim_IPC"

void extractLineWithPrefix(const char *sourceFile, FILE *destFile) {
    FILE *src = fopen(sourceFile, "r");
    if (src == NULL) {
        perror("Error opening source file");
        return;
    }

    char buffer[BUFFER_SIZE];
    while (fgets(buffer, sizeof(buffer), src) != NULL) {
        if (strncmp(buffer, PREFIX, strlen(PREFIX)) == 0) {
            fprintf(destFile, "From file %s: %s", sourceFile, buffer);
            break;
        }
    }

    fclose(src);
}

void processDirectory(const char *dirPath, const char *destFile) {
    DIR *dir = opendir(dirPath);
    if (dir == NULL) {
        perror("Error opening directory");
        exit(EXIT_FAILURE);
    }

    FILE *dst = fopen(destFile, "w");
    if (dst == NULL) {
        perror("Error opening destination file");
        closedir(dir);
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
                extractLineWithPrefix(filepath, dst);
            }
        }
    }

    closedir(dir);
    fclose(dst);
}

int main() {
    const char *directory = ".";
    const char *destFile = "combined_output.txt";

    processDirectory(directory, destFile);

    printf("Lines from .out files starting with '%s' have been extracted and written to %s\n", PREFIX, destFile);

    return 0;
}
