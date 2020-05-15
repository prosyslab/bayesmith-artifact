for file in images/*; do
	./task "$file"|grep '1$' >> /tmp/task.out 2>>/dev/null
done
