## Usage
```bash
docker run -d \
    --cap-add=NET_ADMIN \
    --restart=always \
    --network=host \
    -v /etc/tutacc:/etc/tutacc \
    --name tutacc \
    tutacc/tutacc-core
```
