
exec drop_table('log_table');
begin 
   if not does_table_exist('log_table') then 
      execute immediate q'<
      create table log_table (
      log_id number generated always as identity,
      log_time timestamp default systimestamp,
      log_text varchar2(4000),
      log_type varchar2(25) default 'log' not null,
      log_expires timestamp default null,
      ready_notify number default 0)>';
   end if;
   add_primary_key('log_table', 'log_id');
   if not does_index_exist('log_table_1') then 
      execute immediate q'<create index log_table_1 on log_table (log_time)>';
   end if;
end;
/

-- exec drop_table('cache_table');
begin
   if not does_table_exist('cache_table') then 
      execute immediate q'<create table cache_table (
         cache_key varchar2(512) not null,
         value varchar2(4000) default null,
         updated timestamp default systimestamp)>';
   end if;
   add_primary_key('cache_table', 'cache_key');
   if not does_column_exist('cache_table', 'updated') then 
      execute immediate q'<alter table cache_table add (updated timestamp default systimestamp)>';
   end if;
end;
/

exec drop_table('counter_table');
begin
   if not does_table_exist('counter_table') then 
      execute immediate q'<create table counter_table (
         counter_key varchar2(512) not null,
         value number default null,
         updated timestamp default systimestamp)>';
   end if;
   add_primary_key('counter_table', 'counter_key');
end;
/

exec drop_table('alert_table');
begin 
   if not does_table_exist('alert_table') then 
      execute immediate q'<create table alert_table (
         alert_id number generated always as identity,
         alert_level varchar2(128) default 'warning',
         alert_name varchar2(512) default null,
         alert_info varchar2(4000) default null,
         alert_type varchar2(128) default null,
         -- Number of times a notification was sent
         notify_count number default 0,
         last_notify timestamp default null,
         -- This record will be included in the next notification email.
         ready_notify number default 0,
         opened timestamp default systimestamp,
         updated timestamp default systimestamp,
         closed timestamp default null,
         alert_view varchar2(256) default null,
         -- ToDo: Drop alert_delay
         -- Number of minutes to wait before this row is really considered an alert.
         alert_delay number default 0 not null
         )>';
   end if;
   add_primary_key('alert_table', 'alert_id');
   if not does_index_exist('alert_table_1') then 
      execute immediate q'<create index alert_table_1 on alert_table (alert_name)>';
   end if;
end;
/

-- exec drop_table('stat_table');
begin
   if not does_table_exist('stat_table') then
   execute immediate q'<create table stat_table (
      stat_table_id number generated always as identity,
      stat_name varchar2(255) not null,
      description varchar2(512) default null,
      -- A unique index is on name and stat_group.
      stat_group varchar2(255) not null,
      tags varchar2(255) default null,
      value number default 0,
      value_time timestamp default systimestamp,
      time_delta number default 0,
      delta_value number default 0,
      rate_per_sec number default 0,
      -- In delta, rate, value (rate is rate per second).
      stat_type varchar2(16) default 'value',
      value_convert varchar2(256) default null,
      stat_label varchar2(128) default null,
      -- Most recent value we are tracking based on the stat type.
      stat_value number default 0,
      -- The avg value for the current hour.
      hh24_avg number default null,
      -- A reference value we use as a baseline to compare to.
      ref_val number default null,
      -- Is the hh24_avg or last_val as a % compared to the hr_ref value.
      hh24_pct_of_ref number default null,
      ddd_avg number default null,
      mm_avg number default null,
      -- Is the hh24_avg or the last value / hr_ref.
      rolling_stat_value varchar2(512) default null,
      rolling_hh24_pct_of_ref varchar2(512) default null,
      below_ref_mi number default 0,
      above_ref_mi number default 0,
      ddd_below_ref_hrs number default 0,
      ddd_above_ref_hrs number default 0,
      mm_below_ref_days number default 0,
      mm_above_ref_days number default 0,
      -- stage, inactive, active.
      status varchar2(16) default 'stage',
      hour number default null,
      hour0 number default null,
      hour1 number default null,
      hour2 number default null,
      hour3 number default null,
      hour4 number default null,
      hour5 number default null,
      hour6 number default null,
      hour7 number default null,
      hour8 number default null,
      hour9 number default null,
      hour10 number default null,
      hour11 number default null,
      hour12 number default null,
      hour13 number default null,
      hour14 number default null,
      hour15 number default null,
      hour16 number default null,
      hour17 number default null,
      hour18 number default null,
      hour19 number default null,
      hour20 number default null,
      hour21 number default null,
      hour22 number default null,
      hour23 number default null,
      sun number default null,
      mon number default null,
      tue number default null,
      wed number default null,
      thu number default null,
      fri number default null,
      sat number default null,
      sun_ref number default null,
      mon_ref number default null,
      tue_ref number default null,
      wed_ref number default null,
      thu_ref number default null,
      fri_ref number default null,
      sat_ref number default null,
      jan number default null,
      feb number default null,
      mar number default null,
      apr number default null,
      may number default null,
      jun number default null,
      jul number default null,
      aug number default null,
      sep number default null,
      oct number default null,
      nov number default null,
      dec number default null,
      created timestamp default systimestamp,
      updated timestamp default systimestamp,
      hh24_total number default 0,
      hh24_count number default 0,
      ddd_total number default 0,
      ddd_count number default 0,
      mm_total number default 0,
      mm_count number default 0,
      zero_neg_deltas number default 1,
      neg_delta_count number default 0)>';
   end if;
   add_primary_key('stat_table', 'stat_table_id');
   if not does_index_exist('stat_table_01') then 
      execute immediate q'<create unique index stat_table_01 on stat_table (stat_name, stat_group)>';
   end if;
   if not does_column_exist('stat_table', 'zero_neg_deltas') then 
      execute immediate q'<alter table stat_table add (zero_neg_deltas number default 1)>';
   end if;
   drop_column('stat_table', 'allow_negative_value');
end;
/

-- exec drop_table('sql_snap');
begin
   if not does_table_exist('sql_snap') then 
      execute immediate q'<
      create table sql_snap (
      sql_id                    varchar2(13),
      insert_datetime           date,
      sql_text                  varchar2(100),
      plan_hash_value           number,
      executions                number,
      elapsed_time              number,
      force_matching_signature  number,
      user_io_wait_time         number,
      rows_processed            number,
      cpu_time                  number,
      service                   varchar2(100),
      module                    varchar2(100),
      action                    varchar2(100))>';
   end if;
   if not does_index_exist('sql_snap_1') then
      execute immediate q'<create index sql_snap_1 on sql_snap (sql_id, plan_hash_value, force_matching_signature)>';
   end if;
end;
/

-- exec drop_table('sql_log');
begin 
   if not does_table_exist('sql_log') then
      execute immediate q'<
      create table sql_log (
      sql_log_id                   number generated always as identity,
      sql_id                       varchar2(100),
      sql_text                     varchar2(100),
      plan_hash_value              number,
      plan_age_in_days             number,
      force_matching_signature     number,
      datetime                     date,
      update_count                 number default 0,
      update_time                  date,
      elapsed_seconds              number,
      fms_elapsed_seconds          number,
      elapsed_seconds_ptile        number,
      cpu_seconds                  number,
      user_io_wait_secs            number,
      executions                   number,
      executions_ptile             number,
      elap_secs_per_exe            number,
      elap_secs_per_exe_ptile      number,
      secs_0_1                     number default 0,
      secs_2_5                     number default 0,
      secs_6_10                    number default 0,
      secs_11_60                   number default 0,
      secs_61_plus                 number default 0,
      sql_age_in_days              number,
      rows_processed               number,
      secs_between_snaps           number,
      -- These can be updated manually and still be used even if not available in gv$sql.
      service                      varchar2(128),
      module                       varchar2(128),
      action                       varchar2(128),
      elap_secs_per_exe_med        number,
      elap_secs_per_exe_avg        number)>';
   end if;

   if not does_column_exist('sql_log', 'fms_elapsed_seconds') then
      execute immediate 'alter table sql_log add (fms_elapsed_seconds number)';
   end if;
   
   if not does_index_exist('sql_log_1') then
      execute immediate q'<create index sql_log_1 on sql_log (sql_id, plan_hash_value, force_matching_signature)>';
   end if;

   if not does_index_exist('sql_log_2') then
      execute immediate q'<create index sql_log_2 on sql_log (datetime)>';
   end if;

   if not does_index_exist('sql_log_3') then
      execute immediate q'<create index sql_log_3 on sql_log (plan_hash_value)>';
   end if;

   if not does_index_exist('sql_log_4') then
      execute immediate q'<create index sql_log_4 on sql_log (sql_log_id)>';
   end if;

   if not does_index_exist('sql_log_5') then
      execute immediate q'<create unique index sql_log_5 on sql_log (sql_id, plan_hash_value, force_matching_signature, datetime)>';
   end if;

   if not does_index_exist('sql_log_6') then 
      execute immediate q'<create index sql_log_6 on sql_log (force_matching_signature, datetime)>';
   end if;
   
   drop_column('sql_log', 'faster_plans');
   drop_column('sql_log', 'slower_plans');
   drop_column('sql_log', 'io_wait_secs_score');
   drop_column('sql_log', 'norm_user_io_wait_secs');
   drop_column('sql_log', 'executions_score');
   drop_column('sql_log', 'norm_execs_per_hour');
   drop_column('sql_log', 'elap_secs_per_exe_score');
   drop_column('sql_log', 'norm_elap_secs_per_exe');
   drop_column('sql_log', 'pct_of_elap_secs_for_all_sql');
   drop_column('sql_log', 'sql_last_seen_in_days');
   drop_column('sql_log', 'norm_rows_processed');
   drop_column('sql_log', 'sql_log_score');
   drop_column('sql_log', 'sql_log_total_score');
   drop_column('sql_log', 'sql_log_avg_score');
   drop_column('sql_log', 'rolling_avg_score');
   drop_column('sql_log', 'sql_log_max_score');
   drop_column('sql_log', 'sql_log_min_score');
   drop_column('sql_log', 'sql_log_score_count');
   drop_column('sql_log', 'hours_since_last_exe');

   if not does_column_exist('sql_log', 'elapsed_seconds_ptile') then
      execute immediate 'alter table sql_log add (elapsed_seconds_ptile number)';
   end if;

   if not does_column_exist('sql_log', 'elap_secs_per_exe_ptile') then
      execute immediate 'alter table sql_log add (elap_secs_per_exe_ptile number)';
   end if;

   if not does_column_exist('sql_log', 'executions_ptile') then
      execute immediate 'alter table sql_log add (executions_ptile number)';
   end if;

   drop_column('sql_log', 'elap_secs_per_exe_ref');

   if not does_column_exist('sql_log', 'elap_secs_per_exe_med') then
      execute immediate 'alter table sql_log add (elap_secs_per_exe_med number)';
   end if;

   if not does_column_exist('sql_log', 'elap_secs_per_exe_avg') then
      execute immediate 'alter table sql_log add (elap_secs_per_exe_avg number)';
   end if;

end;
/

-- exec drop_table('config_table');
begin
   if not does_table_exist('config_table') then
      execute immediate '
      create table config_table (
      name varchar2(128),
      value varchar2(1024),
      description varchar2(1024) default null,
      is_numeric number default 0)';
   end if;
   add_primary_key('config_table', 'name');
   if not does_column_exist('config_table', 'description') then 
      execute immediate '
      alter table config_table add (description varchar2(1024) default null)';
   end if;
end;
/

-- exec drop_table('obj_size_data');
begin 
   if not does_table_exist('obj_size_data') then
      execute immediate '
         create table obj_size_data (
         owner           varchar2(30),
         segment_name    varchar2(81),
         partition_name  varchar2(30),
         segment_type    varchar2(17),
         tablespace_name varchar2(30),
         start_date      date default trunc(sysdate),
         start_size      number default 0,
         year            number default to_number(to_char(sysdate,''YYYY'')),
         last_size       number default 0,
         jan             number default 0,
         feb             number default 0,
         mar             number default 0,
         apr             number default 0,
         may             number default 0,
         jun             number default 0,
         jul             number default 0,
         aug             number default 0,
         sep             number default 0,
         oct             number default 0,
         nov             number default 0,
         dec             number default 0,
         updated         date default trunc(sysdate),
         constraint obj_size_data_pk_v2 primary key (owner,segment_name,partition_name,segment_type))';
   end if;
end;
/

exec drop_table('test_table');
begin
   if not does_table_exist('test_table') then 
      execute immediate '
      create table test_table (
      test_id number generated always as identity,
      test_name varchar2(512) not null,
      description varchar2(1024) default null,
      last_try timestamp default null,
      -- pass, fail, error
      status varchar2(8) default null,
      status_time timestamp default null,
      test_group varchar2(256) default null)';
   end if;
   add_primary_key('test_table', 'test_id');
   if not does_index_exist('test_table_1') then 
      execute immediate 'create unique index test_table_1 on test_table(test_name)';
   end if;
end;
/

-- exec drop_table('sensor_table');
begin
   if not does_table_exist('sensor_table') then 
      execute immediate '
      create table sensor_table (
      sensor_id number generated always as identity,
      sensor_name varchar2(128) not null,
      sensor_view varchar2(128) default null,
      -- Last time the sensor was triggered.
      last_time timestamp default null,
      created timestamp default systimestamp,
      updated timestamp default systimestamp)';
   end if;
end;
/

-- exec drop_table('sensor_text');
begin
   if not does_table_exist('sensor_text') then 
      execute immediate '
      create table sensor_text (
      sensor_text_id number generated always as identity,
      sensor_id number not null,
      version varchar2(8) default ''NEW'',
      name varchar2(512) not null,
      value varchar2(4000))';
   end if;
   add_primary_key('sensor_text', 'sensor_text_id');
   if not does_index_exist('sensor_text_1') then 
      execute immediate 'create unique index sensor_text_1 on sensor_text(sensor_id, version, name)';
   end if;
end;
/

-- exec drop_table('sensor_hist');
begin
   if not does_table_exist('sensor_hist') then 
      execute immediate '
      create table sensor_hist (
      sensor_hist_id number generated always as identity,
      sensor_id number not null,
      name varchar2(512) not null,
      old_value varchar2(4000),
      new_value varchar2(4000),
      created timestamp default systimestamp,
      notify_count number default 0,
      last_notify timestamp default null)';
   end if;
   add_primary_key('sensor_hist', 'sensor_hist_id');
   if not does_index_exist('sensor_hist_1') then 
      execute immediate 'create index sensor_hist_1 on sensor_hist(sensor_id, name)';
   end if;
end;
/

exec drop_table('disk_info');
begin
   if not does_table_exist('disk_info') then 
      execute immediate '
      create table disk_info (
      disk_info_id number generated always as identity,
      insert_datetime timestamp default systimestamp not null,
      disk_name varchar2(128) not null,
      pct_free number not null,
      kb_used number not null,
      kb_free number not null)';
   end if;
   add_primary_key('disk_info', 'disk_info_id');
   if not does_index_exist('disk_info_1') then
      execute immediate 'create index disk_info_1 on disk_info(insert_datetime)';
   end if;
   if not does_index_exist('disk_info_2') then 
      execute immediate 'create index disk_info_2 on disk_info(disk_name, insert_datetime)';
   end if;
end;
/

-- exec drop_table('sql_note');
begin
   if not does_table_exist('sql_note') then 
      execute immediate '
      create table sql_note (
      sql_note_id number generated always as identity,
      sql_ref varchar(256) default null,
      -- Either sql_id, plan_hash_value, sql_text
      sql_ref_type varchar2(32) not null,
      sql_note varchar2(1024) not null,
      created timestamp default systimestamp not null)';
   end if;
   add_primary_key('sql_note', 'sql_note_id');
   if not does_index_exist('sql_note_1') then
      execute immediate 'create index sql_note_1 on sql_note(sql_ref)';
   end if;
end;
/

create or replace procedure sql_text_note (
   p_sql_text in varchar2,
   p_sql_note in varchar2
   ) is 
begin
   update sql_note
      set sql_note=p_sql_note
    where sql_ref=p_sql_text
      and sql_ref_type='sql_text';
   if sql%rowcount = 0 then
      insert into sql_note (
         sql_ref,
         sql_ref_type,
         sql_note) values (
         p_sql_text,
         'sql_text',
         p_sql_note);
   end if;
end;
/

-- exec drop_table('blocked_sessions_hist');
begin
   if not does_table_exist('blocked_sessions_hist') then 
      execute immediate '
      create table blocked_sessions_hist (
      blocked_sessions_hist_id number generated always as identity,
      block                   varchar2(128),
      insert_time             timestamp default systimestamp,
      inst_id                 number,
      sid                     number,
      serial#                 number,
      paddr                   varchar2(128),
      spid                    varchar2(128),
      username                varchar2(128),
      process                 varchar2(128),
      machine                 varchar2(128),
      state                   varchar2(128),
      program                 varchar2(128),
      terminal                varchar2(128),
      sql_id                  varchar2(128),
      prev_sql_id             varchar2(128),
      module                  varchar2(128),
      last_call_et            number,
      blocking_instance       number,
      blocking_session        number,
      event                   varchar2(64),
      last_notify             timestamp default null,
      ready_notify            number default 0 not null)';
   end if;
   add_primary_key('blocked_sessions_hist', 'blocked_sessions_hist_id');
   if not does_index_exist('blocked_sessions_hist_1') then 
      execute immediate 'create index blocked_sessions_hist_1 on blocked_sessions_hist(insert_time)';
   end if;
end;
/

begin
   if not does_table_exist('json_store') then 
      execute_sql('
      create table json_store (
      json_store_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      json_key varchar2(256) not null,
      json_data json)', false);
   end if;
   add_primary_key('json_store', 'json_store_id');
   if not does_constraint_exist('check_json_store_json_data') then
      execute_sql('
      alter table json_store
         add constraint check_json_store_json_data check (json_data is json)', false);
   end if;
   if not does_index_exist('unq_json_store_json_key') then
      execute_sql('
      create unique index unq_json_store_json_key on json_store (json_key)', false);
   end if;
end;
/

begin
   if not does_table_exist('json_data') then 
      execute_sql('
      create table json_data (
      json_data_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      json_key varchar2(128) not null,
      json_path varchar2(512) not null,
      data_index number default 0 not null,
      data_type varchar2(32),
      data_size number not null,
      -- data_value varchar2(4000),
      data_value clob,
      data_key varchar2(128) not null)', false);
   end if;
   add_primary_key('json_data', 'json_data_id');
end;
/
