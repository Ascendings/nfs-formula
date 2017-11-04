{% from "nfs/map.jinja" import nfs_settings as nfs with context %}

include:
  - nfs.client

{% for m in salt['pillar.get']('nfs:mount').items() %}
{{ m[1].mountpoint }}:
  mount.mounted:
    - device: {{ m[1].location }}
    - fstype: nfs
{% if m[1].nfsv4 %}
  {% if salt['grains.get']('os_family') == 'FreeBSD' %}
    - opts: {{ m[1].opts|default('ro') }},nfsv4
    - extra_mount_invisible_options:
      - nfsv4
    - extra_mount_invisible_keys:
      - proto
      - port
  {% else %}
    - opts: {{ m[1].opts|default('ro') }},vers=4.0
  {% endif %}
{% else %}
    - opts: {{ m[1].opts|default('ro') }}
{% endif %}
    - persist: {{ m[1].persist|default('True') }}
    - mkmnt: {{ m[1].mkmnt|default('True') }}
{% endfor %}

