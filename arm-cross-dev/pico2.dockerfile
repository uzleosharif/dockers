

# a convenient dockerfile to develop C++ stuff for pico2 board

# we derive from `dockers/arm-cross-dev/base.dockerfile`
FROM arm-cross-dev-base:1.0.0

# use latest codex tool
RUN \
  npm i -g @openai/codex


# ARM Toolchain for Embedded (ATfE) aka llvm toolchain for embedded-arm

