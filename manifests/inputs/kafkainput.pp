# Input plugin that connects to a Kafka broker and subscribes to messages from the specified topic and partition
#
# === Parameters:
#
# $ensure::                       This is used to set the status of the config file: present or absent
#                                 Default: present
#
### Common Input Parameters::     Check heka::inputs::tcpinput for the description
#
### Kafka Input Parameters
#
# $id::                           Client ID string.
#                                 Default is the hostname.
#                                 Type: string
#
# $addrs::                        List of brokers addresses.
#                                 Type: []string
#
# $metadata_retries::             How many times to retry a metadata request when a partition is in the middle of leader election.
#                                 Default is 3.
#                                 Type: int
#
# $wait_for_election::            How long to wait for leader election to finish between retries (in milliseconds).
#                                 Default is 250.
#                                 Type: uint32
#
# $background_refresh_frequency:: How frequently the client will refresh the cluster metadata in the background (in milliseconds).
#                                 Default is 600000 (10 minutes). Set to 0 to disable.
#                                 Type: uint32
#
# $max_open_reqests::             How many outstanding requests the broker is allowed to have before blocking attempts to send.
#                                 Default is 4.
#                                 Type: int
#
# $dial_timeout::                 How long to wait for the initial connection to succeed before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $read_timeout::                 How long to wait for a response before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $write_timeout::                How long to wait for a transmit to succeed before timing out and returning an error (in milliseconds).
#                                 Default is 60000 (1 minute).
#                                 Type: uint32
#
# $topic::                        Kafka topic (must be set).
#                                 Type: string
#
# $partition::                    Kafka topic partition.
#                                 Default is 0.
#                                 Type: int32
#
# $group::                        A string that uniquely identifies the group of consumer processes to which this consumer belongs.
#                                 By setting the same group id multiple processes indicate that they are all part of the same consumer group.
#                                 Default is the id.
#                                 Type: string
#
# $default_fetch_size::           The default (maximum) amount of data to fetch from the broker in each request.
#                                 The default is 32768 bytes.
#                                 Type: int32
#
# $min_fetch_size::               The minimum amount of data to fetch in a request - the broker will wait until at least this many bytes are available.
#                                 The default is 1, as 0 causes the consumer to spin when no messages are available.
#                                 Type: int32
#
# $max_message_size::             The maximum permittable message size - messages larger than this will return MessageTooLarge.
#                                 The default of 0 is treated as no limit.
#                                 Type: int32
#
# $max_wait_time::                The maximum amount of time the broker will wait for min_fetch_size bytes
#                                 to become available before it returns fewer than that anyways.
#                                 The default is 250ms, since 0 causes the consumer to spin when no events are available.
#                                 100-500ms is a reasonable range for most cases.
#                                 Type: uint32
#
# $offset_method::                The method used to determine at which offset to begin consuming messages. The valid values are:
#                                  - "Manual" Heka will track the offset and resume from where it last left off (default).
#                                  - "Newest" Heka will start reading from the most recent available offset.
#                                  - "Oldest" Heka will start reading from the oldest available offset.
#                                 Type: string
#
# $event_buffer_size::            The number of events to buffer in the Events channel. Having this non-zero permits the consumer to
#                                 continue fetching messages in the background while client code consumes events,greatly improving throughput.
#                                 The default is 16.
#                                 Type: int
#
define heka::inputs::kafkainput (
  $ensure                       = 'present',
  # Common Input Parameters
  $splitter                     = 'TokenSplitter',
  $decoder                      = undef,
  $synchronous_decode           = undef,
  $send_decode_failures         = undef,
  $can_exit                     = undef,
  # Kafka Input
  $id                           = undef,
  # lint:ignore:parameter_order
  $addrs,
  # lint:endignore
  $metadata_retries             = undef,
  $wait_for_election            = undef,
  $background_refresh_frequency = undef,
  $max_open_reqests             = undef,
  $dial_timeout                 = undef,
  $read_timeout                 = undef,
  $write_timeout                = undef,
  # lint:ignore:parameter_order
  $topic,
  # lint:endignore
  $partition                    = undef,
  $group                        = undef,
  $default_fetch_size           = undef,
  $min_fetch_size               = undef,
  $max_message_size             = undef,
  $max_wait_time                = undef,
  $offset_method                = undef,
  $event_buffer_size            = undef,
) {
  validate_re($ensure, '^(present|absent)$')
  # Common Input Parameters
  if $splitter { validate_string($splitter) }
  if $decoder { validate_string($decoder) }
  if $synchronous_decode { validate_bool($synchronous_decode) }
  if $send_decode_failures { validate_bool($send_decode_failures) }
  if $can_exit { validate_bool($can_exit) }
  # Kafka Input
  if $id { validate_string($id) }
  validate_array($addrs)
  if $metadata_retries { validate_integer($metadata_retries) }
  if $wait_for_election { validate_integer($wait_for_election) }
  if $background_refresh_frequency { validate_integer($background_refresh_frequency) }
  if $max_open_reqests { validate_integer($max_open_reqests) }
  if $dial_timeout { validate_integer($dial_timeout) }
  if $read_timeout { validate_integer($read_timeout) }
  if $write_timeout { validate_integer($write_timeout) }
  validate_string($topic)
  if $partition {validate_integer($partition) }
  if $group { validate_string($group) }
  if $default_fetch_size { validate_integer($default_fetch_size) }
  if $min_fetch_size { validate_integer($min_fetch_size) }
  if $max_message_size { validate_integer($max_message_size) }
  if $max_wait_time { validate_integer($max_wait_time) }
  if $offset_method { validate_re($offset_method, '^(Manual|Newest|Oldest)$') }
  if $event_buffer_size { validate_integer($event_buffer_size) }

  $full_name = "kafkainput_${name}"
  heka::snippet { $full_name:
    ensure  => $ensure,
    content => template("${module_name}/plugin/kafkainput.toml.erb"),
  }
}
