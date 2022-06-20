#!make

.DEFAULT_GOAL := run

docker:
	docker build -t ghcr.io/kilip/workstation:latest .

run:
	docker run -it --tty --volume="${PWD}:/workstation:ro" ghcr.io/kilip/workstation:latest
