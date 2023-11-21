FROM python
ADD requirements.txt /
RUN pip install -r /requirements.txt
ADD plex_auth.py /
ADD untitled2.py /
ENV PYTHONUNBUFFERED=1
CMD ["python","./Plex_update.py"]
