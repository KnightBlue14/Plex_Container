FROM python
ADD requirements.txt /
RUN pip install -r /requirements.txt
ADD plex_auth.py /
ADD Plex_update.py /
ENV PYTHONUNBUFFERED=1
CMD ["python","./Plex_update.py"]
