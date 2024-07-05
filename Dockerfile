FROM alpine:edge

ENV HOME /root
ENV COMPLETIONS /usr/share/bash-completion/completions

# Basic scripts and configs
COPY .bashrc $HOME/.bashrc
COPY .bash_completion $HOME/.bash_completion
COPY .nanorc $HOME/.nanorc
COPY config $HOME/.kube/config
COPY config.yml $HOME/config.yml
COPY create_cluster.sh $HOME/create_cluster.sh
COPY Pipfile* $HOME/
COPY start.sh /tmp/start.sh

# Copy the installation script
COPY install.sh /tmp/install.sh

# Set permissions and run the installation script
RUN chmod +x /tmp/install.sh /tmp/start.sh $HOME/create_cluster.sh \
	&& chmod o-r $HOME/.kube/config \
	&& chmod g-r $HOME/.kube/config \
	&& /tmp/install.sh \
	&& rm /tmp/install.sh

# Set environment for unicode
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Prompt
ENV PS1 "\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "

# Add a Welcome Message
COPY welcome_message.sh /tmp/welcome_message.sh
RUN cat /tmp/welcome_message.sh >> $HOME/.bashrc \
	&& rm /tmp/welcome_message.sh

ENTRYPOINT ["/tmp/start.sh"]

CMD ["bash"]
