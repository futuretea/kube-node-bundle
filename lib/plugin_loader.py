#!/usr/bin/env python3

import os
import yaml
import importlib.util
import sys

class PluginLoader:
    def __init__(self, plugin_dir):
        self.plugin_dir = plugin_dir
        self.collectors = {}
        self.reporters = {}
        
    def load_collectors(self):
        collector_dir = os.path.join(self.plugin_dir, 'collectors')
        for file in os.listdir(collector_dir):
            if file.endswith('.yml'):
                with open(os.path.join(collector_dir, file), 'r') as f:
                    collector = yaml.safe_load(f)
                    if collector.get('enabled', True):
                        self.collectors[collector['name']] = collector
        return self.collectors
    
    def load_reporters(self):
        reporter_dir = os.path.join(self.plugin_dir, 'reporters')
        for file in os.listdir(reporter_dir):
            if file.endswith('.py') and file != '__init__.py':
                module_name = file[:-3]
                module_path = os.path.join(reporter_dir, file)
                
                spec = importlib.util.spec_from_file_location(module_name, module_path)
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                
                # Find reporter class in module
                for attr_name in dir(module):
                    attr = getattr(module, attr_name)
                    if isinstance(attr, type) and hasattr(attr, 'generate'):
                        reporter = attr()
                        self.reporters[reporter.name] = reporter
        
        return self.reporters
    
    def get_enabled_collectors(self):
        return {name: collector for name, collector in self.collectors.items() 
                if collector.get('enabled', True)}
    
    def get_collector_commands(self):
        commands = []
        for collector in self.get_enabled_collectors().values():
            commands.extend(collector.get('commands', []))
        return commands
    
    def get_collector_scripts(self):
        scripts = []
        for collector in self.get_enabled_collectors().values():
            scripts.extend(collector.get('scripts', []))
        return scripts 

def load_collectors():
    collectors = []
    collector_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'plugins/collectors')
    
    if os.path.exists(collector_dir):
        for file in os.listdir(collector_dir):
            if file.endswith('.yml'):
                with open(os.path.join(collector_dir, file), 'r') as f:
                    collector = yaml.safe_load(f)
                    if collector.get('enabled', True):
                        collectors.append(collector)
    
    return collectors

def main():
    if '--list-collectors' in sys.argv:
        collectors = load_collectors()
        print(yaml.dump(collectors))

if __name__ == '__main__':
    main()
