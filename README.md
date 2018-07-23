# soultalk

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## SQLite
CREATE VIRTUAL TABLE enrondata1 USING fts3(content TEXT);
SELECT count(*) FROM enrondata1 WHERE content MATCH 'linux';
