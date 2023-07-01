

# this relies on a docker image built using ubuntu-nvim.dockerfile to be 
# already available. We look for this image as 'nvim-ub'
# this provides nvim editor, lazygit, c++ compilers
FROM nvim-ub

RUN apt update && apt upgrade -y && apt install -y latexmk texlive \
    texlive-lang-german texlive-latex-extra texlive-fonts-extra
