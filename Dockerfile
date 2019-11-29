# syntax=docker/dockerfile:experimental

ARG ALPINE_OS_VERSION="3.8"

#### Builder ####
FROM alpine:${ALPINE_OS_VERSION} AS builder
LABEL maintainer="ryucrosskey@gmail.com"
WORKDIR /home/vim
RUN apk add --no-cache --virtual .dev \
        gcc \
	gfortran \
        libc-dev \
        make \
        gettext \
  	mercurial \
	ncurses-dev \
    && apk add --no-cache \
        git \
	lua lua-dev luajit-dev\
	python-dev \
	python3-dev \
	ruby ruby-dev \
  	perl-dev \
    && git clone https://github.com/vim/vim.git \
    && cd vim \
    && ./configure \
        --enable-gui=gtk3 \
        --enable-perlinterp \
        --enable-pythoninterp \
        --enable-python3interp \
        --enable-rubyinterp \
        --enable-luainterp --with-luajit \
        --enable-fail-if-missing \
    && make \
    && make install


#### vim container ####
FROM alpine:${ALPINE_OS_VERSION}
ENV VIM_USER vim
ENV VIM_GROUP vim
ENV VIM_SHELL /bin/sh
ENV HOME /home/${VIM_USER}

WORKDIR ${HOME}

RUN addgroup -S ${VIM_GROUP} \
    && adduser -S ${VIM_USER} -G ${VIM_GROUP} \
    && echo "${VIM_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo 'vim:vim' | chpasswd \
    && apk update \
    && apk add --no-cache --virtual .dev \
	curl=7.61.1-r3\
        git=2.18.1-r0 \
	lua-dev \
	luajit-dev\
	python-dev \
	python3-dev \
	ruby \
	ruby-dev \
  	perl-dev \
	npm=8.14.0-r0 \
	yarn=1.7.0-r0 \
	zsh=5.5.1-r0 \
    && mkdir -p ${HOME}/.cache/dein ${HOME}/.vim \
    && curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh \
    && sh ./installer.sh /home/vim/.cache/dein \
    && git clone https://github.com/zplug/zplug ${HOME}/.zplug \
    && pip3 install -U pip==19.3.1 \
    && pip3 install jedi==0.15.1 \
    && chown -R ${VIM_USER}:${VIM_GROUP} ${HOME}

USER ${VIM_USER}:${VIM_GROUP}

COPY --from=builder /usr/local/ /usr/local/
COPY --chown=${VIM_USER}:${VIM_GROUP} config/vimrc ${HOME}/.vimrc
COPY --chown=${VIM_USER}:${VIM_GROUP} config/zshrc ${HOME}/.zshrc
COPY --chown=${VIM_USER}:${VIM_GROUP} config/dein.toml ${HOME}/.vim/dein.toml

SHELL ["/bin/sh"]
ENTRYPOINT ["/bin/zsh"]
