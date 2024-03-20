FROM pydemia/debug-slim
LABEL maintainer="Youngju Jaden Kim <pydemia@gmail.com>"

# ENV DEBIAN_FRONTEND noninteractive
# RUN apt update && \
#     apt install -y -qq dnsutils curl git vim

RUN apt-get update -q

# azul openjdk and maven
RUN apt-get install -y software-properties-common gnupg ca-certificates curl && \
    curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list && \
    apt-get update -q && apt-get install -y zulu17-jdk maven

ENV JAVA_HOME="/usr/lib/jvm/zulu17-ca-amd64"


# google-cloud-sdk
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && apt-get install google-cloud-sdk -y

# aws cli 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# azure cli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# k9s
RUN k9s_version="v0.27.2" && \
    k_os_type="linux" && \
    curl -L https://github.com/derailed/k9s/releases/download/"${k9s_version}"/k9s_"$(echo "${k_os_type}" |sed 's/./\u&/')"_amd64.tar.gz -o k9s.tar.gz && \
    mkdir -p ./k9s && \
    tar -zxf k9s.tar.gz -C ./k9s && \
    mv ./k9s/k9s /usr/local/bin/ && \
    rm -rf ./k9s ./k9s.tar.gz && \
    echo "\nInstalled in: $(which k9s)"

# postgresql
#RUN apt install postgresql -y 16 on 22.04, 12 on 20.04
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc| gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    apt update -y && \
    apt install postgresql-16 -y

RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# VIM IDE
RUN git clone https://github.com/rapphil/vim-python-ide.git vim-python-ide && \
    cd vim-python-ide && echo ""| echo ""| ./install.sh
RUN cd .. && rm -rf vim-python-ide && \
    sed -i 's/^colorscheme cobalt2/"colorscheme Monokai\ncolorscheme cobalt2/' ~/.vimrc

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# ENTRYPOINT ["/bin/bash"]
