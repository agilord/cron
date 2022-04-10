// Copyright (c) 2022, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Exception thrown when a cron data does not have an expected
/// format and cannot be parsed or processed.
class ScheduleParseException extends FormatException {
  /// Creates a new `FormatException` with an optional error [message].
  ScheduleParseException([String message = '']) : super(message);
}
