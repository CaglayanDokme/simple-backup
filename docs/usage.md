# Usage

```bash
bkp [OPTIONS] <path1> [path2] ...
```

## Options

- `-c, --compress[=MODE]`: Create a compressed tar.gz backup. `MODE` can be `merged` (default) or `separate`. Requires `tar` and `gzip` only when used.
- `-a, --archive-name NAME`: Set the merged archive name. Required when merged compression targets multiple files or directories.
- `-f, --force`: Overwrite existing backup files or directories.
- `-s, --symbolic`: Follow symbolic links. By default, errors if a symlink is encountered.
- `-r, --recursive`: Allow backing up directories.
- `-t, --timestamp`: Add a timestamp to the backup name: `<name>.<timestamp>.bkp`.
- `-m, --move`: Move the resource instead of copying it.
- `-d, --destination DIR`: Specify a target directory for backups.
- `-e, --exclude PATTERN`: Exclude matching files or folders using shell-style glob patterns. Repeat the flag to add more patterns.
- `-v, --version`: Show version information.
- `-h, --help`: Show this help message.

## Examples

1. **Basic Backup:**
   ```bash
   bkp file.txt # Creates file.txt.bkp
   ```

2. **Compressed Backup:**
   ```bash
   bkp -c file.txt # Creates file.txt.bkp.tar.gz
   ```

3. **Merged Compressed Backup for Multiple Targets:**
   ```bash
   bkp -c -a snapshot file.txt notes.txt # Creates snapshot.bkp.tar.gz containing both files
   ```

4. **Separate Compressed Backups for Multiple Targets:**
   ```bash
   bkp --compress=separate file.txt notes.txt # Creates file.txt.bkp.tar.gz and notes.txt.bkp.tar.gz
   ```

5. **Move and Timestamp:**
   ```bash
   bkp -mt file.txt # Moves file.txt to file.txt.20231024.bkp
   ```

6. **Recursive Folder Backup:**
   ```bash
   bkp -r my_folder # Creates my_folder.bkp
   ```

7. **Follow Symlinks:**
   ```bash
   bkp -s my_link # Backs up the actual file my_link points to.
   ```

8. **Exclude Generated Files:**
   ```bash
   bkp -r -e '*.o' -e '*.tmp' project
   ```

9. **Exclude a Folder While Moving:**
   ```bash
   bkp -mr -e node_modules app
   ```