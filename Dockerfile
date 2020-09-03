# syntax=docker/dockerfile:experimental
FROM gentoo/portage:latest as portage
FROM gentoo/stage3-amd64:latest

RUN touch /etc/init.d/functions.sh && \
  echo 'PYTHON_TARGETS="${PYTHON_TARGETS} python3_7"' >> /etc/portage/make.conf && \
  echo 'PYTHON_SINGLE_TARGET="python3_7"' >> /etc/portage/make.conf

RUN --mount=type=cache,from=portage,source=/var/db/repos,target=/var/db/repos --mount=type=tmpfs,target=/var/tmp/portage emerge gcc distcc

RUN ( \
    echo "#!/bin/sh" && \
    echo "eval \"\`gcc-config -E\`\"" && \
    echo "exec distccd \"\$@\"" \
  ) > /usr/local/sbin/distccd-launcher && \
  chmod +x /usr/local/sbin/distccd-launcher

CMD ["/usr/local/sbin/distccd-launcher", "--allow", "0.0.0.0/0", "--user", "distcc", "--log-level", "notice", "--log-stderr", "--no-detach"]

EXPOSE 3632
