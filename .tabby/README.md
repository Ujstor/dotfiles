# docker start command

```bash
docker run -it --gpus all \
  --restart unless-stopped \
  -p 8080:8080 -v $HOME/.tabby:/data \
  tabbyml/tabby serve --model DeepseekCoder-6.7B --chat-model CodeQwen-7B-Chat --device cuda
```


## Unit

```bash
cp tabby.service /etc/systemd/system/tabby.service

sudo systemctl daemon-reload
sudo systemctl enable tabby
sudo systemctl start tabby
```
