## force renew certificate

```
sudo sh /root/.acme.sh/acme.sh --renew-all --force
```

## install cronjob to auto renew
Only if not installed

```
sudo sh /root/.acme.sh/acme.sh --install-cronjob
```

## reload wings
```
sudo systemctl restart wings
```
