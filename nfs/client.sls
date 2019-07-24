{% from "nfs/map.jinja" import nfs_settings as nfs with context %}

{% if nfs.pkgs_client %}
nfs-client-deps:
  pkg.installed:
    - pkgs: {{ nfs.pkgs_client|json }}
{% endif %}

{% if nfs.service_client %}
nfs-service:
  service.running:
    - name: {{ nfs.service_client }}
    - enable: True
{% endif %}

{% if nfs.nfsv4_client_enable and salt['grains.get']('os') == 'FreeBSD' %}
nfsv4_userd_service:
  service.running:
    - name: nfsuserd
    - enable: True
{% endif %}

{% if nfs.idmapd_manage %}
idmapd_conf:
  file.managed:
    - source: salt://nfs/files/idmapd.conf
    - name: {{ nfs.idmapd_conf }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja

idmapd_service:
  service.running:
    - name: {{ nfs.idmapd_service }}
    - watch:
      - file: idmapd_conf
{% endif %}

