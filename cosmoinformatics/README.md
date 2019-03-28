to build: 
  `docker build --build-arg SSH_PRIVATE="$(cat ~/.ssh/id_rsa)" -t cosmoinformatics .`
  
to run:
  `docker run -it --rm cosmoinformatics`
