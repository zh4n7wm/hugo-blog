.PHONY: html, push, clean

PUBLIC_DIR:=../github-blog-public
PUBLIC_REPO:=git@github.com:ox0spy/ox0spy.github.io.git

html: clean
	hugo --theme even

push: html
	{ test -d ${PUBLIC_DIR}/.git && git -C ${PUBLIC_DIR} pull origin master || git clone ${PUBLIC_REPO} ${PUBLIC_DIR} ;} && \
		cp -rf public/* ${PUBLIC_DIR} && \
		cd ${PUBLIC_DIR} && \
		git add -f --all && \
		git commit -m 'auto update.' && \
		git push -f -q ${PUBLIC_REPO}
	make clean

clean:
	@rm -rf public/
