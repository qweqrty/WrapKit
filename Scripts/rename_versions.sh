find . -type f -name '*iOS18.3.1_*' -exec bash -c '
for f; do
  mv "$f" "${f/iOS18.3.1_/iOS18.5_}"
done
' bash {} +