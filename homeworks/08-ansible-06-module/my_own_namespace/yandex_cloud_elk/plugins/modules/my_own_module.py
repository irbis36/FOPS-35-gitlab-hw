#!/usr/bin/python

# Copyright: (c) 2024, Vladimir Larin
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: Module for creating text files

version_added: "1.0.0"

description: This module creates a text file on a remote host with specified path and content.

options:
    path:
        description: The path where the file should be created.
        required: true
        type: str
    content:
        description: The content to write into the file.
        required: true
        type: str

author:
    - Vladimir Larin (@vlarind)
'''

EXAMPLES = r'''
- name: Create a file with content
  my_own_namespace.yandex_cloud_elk.my_own_module:
    path: /tmp/test_file.txt
    content: "Hello, Netology!"
'''

RETURN = r'''
message:
    description: The output message.
    type: str
    returned: always
    sample: 'File created'
'''

import os
import hashlib
from ansible.module_utils.basic import AnsibleModule


def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']

    new_hash = hashlib.md5(content.encode('utf-8')).hexdigest()

    if os.path.exists(path):
        with open(path, 'r') as f:
            existing = f.read()
        old_hash = hashlib.md5(existing.encode('utf-8')).hexdigest()
        if old_hash == new_hash:
            result['changed'] = False
            result['message'] = 'File already exists with same content'
            module.exit_json(**result)

    result['changed'] = True

    if module.check_mode:
        module.exit_json(**result)

    try:
        with open(path, 'w') as f:
            f.write(content)
        result['message'] = 'File created successfully'
    except Exception as e:
        module.fail_json(msg='Failed to create file: %s' % str(e), **result)

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
