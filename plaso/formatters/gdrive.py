# -*- coding: utf-8 -*-
"""This file contains a formatter for the Google Drive snaphots."""

from plaso.formatters import interface
from plaso.formatters import manager


__author__ = 'David Nides (david.nides@gmail.com)'


class GDriveCloudEntryFormatter(interface.ConditionalEventFormatter):
  """Formatter for Google Drive snapshot cloud entry."""

  DATA_TYPE = 'gdrive:snapshot:cloud_entry'

  FORMAT_STRING_PIECES = [
      u'File Path: {path}',
      u'[{shared}]',
      u'Size: {size}',
      u'URL: {url}',
      u'Type: {document_type}']
  FORMAT_STRING_SHORT_PIECES = [u'{path}']

  SOURCE_LONG = 'Google Drive (cloud entry)'
  SOURCE_SHORT = 'LOG'


class GDriveLocalEntryFormatter(interface.ConditionalEventFormatter):
  """Formatter for Google Drive snapshot local entry."""

  DATA_TYPE = 'gdrive:snapshot:local_entry'

  FORMAT_STRING_PIECES = [
      u'File Path: {path}',
      u'Size: {size}']

  FORMAT_STRING_SHORT_PIECES = [u'{path}']

  SOURCE_LONG = 'Google Drive (local entry)'
  SOURCE_SHORT = 'LOG'


manager.FormattersManager.RegisterFormatters([
    GDriveCloudEntryFormatter, GDriveLocalEntryFormatter])
