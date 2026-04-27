# Usage

```bash
bkp [OPTIONS] <path1> [path2] ...
```

## Options

- `-c, --compress[=MODE]`: Create a compressed tar.gz backup. `MODE` can be `merged` (default) or `separate`. Requires `tar` and `gzip` only when used.
- `-a, --archive-name NAME`: Set the merged archive name. Required when merged compression targets multiple files or directories. Without `-d`, the archive is written to the shared parent directory of the targets.
- `-f, --force`: Overwrite existing backup files or directories.
- `-s, --symbolic`: Follow symbolic links. By default, errors if a symlink is encountered.
- `-r, --recursive`: Allow backing up directories.
- `-t, --timestamp`: Add a timestamp to the backup name: `<name>.<timestamp>.bkp`.
- `-m, --move`: Move the resource instead of copying it.
- `-d, --destination DIR`: Specify a target directory for backups. Required for merged compression when the targets do not share one parent directory.
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

4. **Merged Backup Written Beside Nested Targets:**
   ```bash
   bkp -c -a snapshot drafts/one.txt drafts/two.txt # Creates drafts/snapshot.bkp.tar.gz
   ```

5. **Separate Compressed Backups for Multiple Targets:**
   ```bash
   bkp --compress=separate file.txt notes.txt # Creates file.txt.bkp.tar.gz and notes.txt.bkp.tar.gz
   ```

6. **Move and Timestamp:**
   ```bash
   bkp -mt file.txt # Moves file.txt to file.txt.20231024.bkp
   ```

7. **Recursive Folder Backup:**
   ```bash
   bkp -r my_folder # Creates my_folder.bkp
   ```

8. **Follow Symlinks:**
   ```bash
   bkp -s my_link # Backs up the actual file my_link points to.
   ```

9. **Exclude Generated Files:**
   ```bash
   bkp -r -e '*.o' -e '*.tmp' project
   ```

10. **Exclude a Folder While Moving:**
   ```bash
   bkp -mr -e node_modules app
   ```

11. **Merged Targets Across Different Directories:**
   ```bash
   bkp -c -a snapshot app/config.yml etc/nginx.conf # Fails unless -d DIR is also provided
   ```