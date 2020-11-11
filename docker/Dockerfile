FROM archlinux/base
ARG TIMEZONE='UTC'
RUN pacman --noconfirm -Sy archlinux-keyring && \
    pacman --noconfirm -S expect sed tar arch-install-scripts && \
    pacman -Scc
ADD ./build.sh /usr/local/bin
ADD ./build-helper.sh /usr/local/bin
RUN sed -i 's/TIMEZONE/$TIMEZONE/g' /usr/local/bin/build-helper.sh
ADD ./build-pacman.conf /usr/local/etc
ADD https://www.blackarch.org/strap.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/strap.sh
VOLUME ["/output"]
WORKDIR /output
ENTRYPOINT ["/usr/local/bin/build.sh"]
