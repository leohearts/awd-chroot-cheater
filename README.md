# AWD chroot cheater

Prevent php from accessing `/flag` by using chroot.

## Usage:

```bash
./run.sh /var/www/html  # create a copy in /tmp/htmlbackup and run
```

or ..

```bash
./run.sh -r /tmp/htmlbackup # run with an existing environment
```