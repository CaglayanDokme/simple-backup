# Usage

```bash
bkp [OPTIONS] <path1> [path2] ...
```

## Options

- `-f, --force`: Overwrite existing backup files or directories.
- `-s, --symbolic`: Follow symbolic links. By default, errors if a symlink is encountered.
- `-r, --recursive`: Allow backing up directories.
- `-t, --timestamp`: Add a timestamp to the backup name: `<name>.<timestamp>.bkp`.
- `-m, --move`: Move the resource instead of copying it.
- `-d, --destination DIR`: Specify a target directory for backups.
- `-v, --version`: Show version information.
- `-h, --help`: Show this help message.

## Examples

1. **Basic Backup:**
   ```bash
   bkp file.txt # Creates file.txt.bkp
   ```

2. **Move and Timestamp:**
   ```bash
   bkp -mt file.txt # Moves file.txt to file.txt.20231024.bkp
   ```

3. **Recursive Folder Backup:**
   ```bash
   bkp -r my_folder # Creates my_folder.bkp
   ```

4. **Follow Symlinks:**
   ```bash
   bkp -s my_link # Backs up the actual file my_link points to.
   ```