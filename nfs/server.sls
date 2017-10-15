{% from "nfs/map.jinja" import nfs_settings as nfs with context %}

{#  FreeBSD has everything needed for NFS w/o any
    additional pkgs, so pkgs_server == False #}
{% if nfs.pkgs_server %}
nfs-server-deps:
  pkg.installed:
    - pkgs: {{ nfs.pkgs_server|json }}
{% endif %}

/etc/exports:
  file.managed:
    - source: salt://nfs/files/exports
    - template: jinja

{# RedHat-based OSes requires to start rpcbind first
    and in some versions there is a bug that it does not start as a dependency #}
{% if nfs.service_server_dependency %}
nfs-service-dependency:
  service.running:
    - name: {{ nfs.service_server_dependency }}
    - enable: True
{% endif %}

{% if nfs.service_server is list %}
  {% for service in nfs.service_server %}
nfs-service_{{ service }}:
  service.running:
    - name: {{ service }}
    - enable: True
    - watch:
      - file: /etc/exports
  {% endfor %}
{% else %}
nfs-service_{{ nfs.service_server }}:
  service.running:
    - name: {{ nfs.service_server }}
    - enable: True
    - watch:
      - file: /etc/exports
{% endif %}

{# This is needed for FreeBSD-based OSes to have an NFSv4 server #}
{% if nfs.nfsv4_server_enable %}
nfsv4_service:
  file.append:
    - name: /etc/rc.conf
    - text: 'nfsv4_server_enable="YES"'
    - watch_in:
    {% if nfs.service_server is list %}
      {% for service in nfs.service_server %}
      - service: {{ service }}
      {% endfor %}
    {% else %}
      - service: {{ nfs.service_server }}
    {% endif %}
{% endif %}
