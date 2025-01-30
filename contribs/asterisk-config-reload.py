# Copyright 2024 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later

import logging
import os
import subprocess
import yaml

from time import sleep
from wazo_bus.consumer import BusConsumer as BaseConsumer

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

conf = {
    "bus": {
        "enabled": True,
        "username": "guest",
        "password": "guest",
        "host": "rabbitmq",
        "port": 5672,
        "exchange_name": "wazo-headers",
        "exchange_type": "headers",
    }
}


class BusConsumer(BaseConsumer):
    @classmethod
    def from_config(cls, bus_config):
        return cls(name="wazo-hackathon-2024", **bus_config)


bus_consumer = BusConsumer.from_config(conf["bus"])

logger.info("bus consumer created")

dir_path = os.path.dirname(os.path.realpath(__file__))

with bus_consumer:
    with open(f"{dir_path}/events-triggers.yml", "r") as f:
        data = yaml.safe_load(f)
        for trigger in data["triggers"]:
            actions = trigger["actions"]
            for event in trigger["events"]:

                def dispatch(payload):
                    logger.info(f"event {event} triggered")
                    for action in actions:
                        subprocess.run(["asterisk", "-rx", action])

                logger.info(f"created handler for {event}")
                bus_consumer.subscribe(event, dispatch)

    while True:
        sleep(1)
