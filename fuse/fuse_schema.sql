exec drop_table('ai_provider');
begin
   if not does_table_exist('ai_provider') then 
      execute immediate '
      create table ai_provider (
      provider_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      provider_name varchar2(512) not null,
      provider_url varchar2(512) not null,
      provider_api_key varchar2(512) not null,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('ai_provider', 'provider_id');
   if not does_index_exist('ai_provider_01') then
      execute immediate 'create unique index ai_provider_01 on ai_provider(provider_name)';
   end if;
end;
/

begin
   insert into ai_provider (provider_name, provider_url, provider_api_key) values ('together', 'https://api.together.xyz/v1/chat/completions', fuse_config.together_api_key);
   insert into ai_provider (provider_name, provider_url, provider_api_key) values ('anthropic', 'https://api.anthropic.com/v1/messages', fuse_config.anthropic_api_key);
end;
/

exec drop_table('ai_model');
begin
   if not does_table_exist('ai_model') then 
      execute immediate '
      create table ai_model (
      model_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      model_name varchar2(512) not null,
      -- Chat, Lang, Code, Image
      model_type varchar2(32) not null,
      provider_id number not null,
      context_length number not null,
      json_mode varchar2(1) default ''N'')';
   end if;
   add_primary_key('ai_model', 'model_id');
   if not does_constraint_exist('fk_ai_model_provider_id') then
      execute immediate 'alter table ai_model add constraint fk_ai_model_provider foreign key (provider_id) references ai_provider(provider_id)';
   end if;
   if not does_index_exist('ai_model_01') then
      execute immediate 'create unique index ai_model_01 on ai_model(model_name)';
   end if;
end;
/

create or replace procedure add_model (
   p_model_name in varchar2,
   p_model_type in varchar2,
   p_provider_name in varchar2,
   p_context_length in number) is
begin

   insert into ai_model (
      model_name,
      model_type,
      provider_id,
      context_length) values (
      p_model_name,
      p_model_type,
      (select provider_id from ai_provider where provider_name=p_provider_name),
      p_context_length);
end;
/

-- together
exec add_model('codellama/CodeLlama-7b-Instruct-hf', 'Chat', 'together', 16384);
exec add_model('codellama/CodeLlama-34b-Instruct-hf', 'Chat', 'together', 16384);
exec add_model('mistralai/Mistral-7B-Instruct-v0.2', 'Chat', 'together', 32768);
exec add_model('google/gemma-7b-it', 'Chat', 'together', 8192);
exec add_model('databricks/dbrx-instruct', 'Chat', 'together', 32768);
-- Supports function calling and json_mode.
exec add_model('togethercomputer/CodeLlama-34b-Instruct', 'Chat', 'together', 16384);
exec add_model('mistralai/Mistral-7B-Instruct-v0.1', 'Chat', 'together', 8192);
exec add_model('mistralai/Mixtral-8x7B-Instruct-v0.1', 'Chat', 'together', 0);

-- anthropic.ai
exec add_model('claude-3-opus-20240229', 'Chat', 'anthropic', 200000);
exec add_model('claude-3-sonnet-20240229', 'Chat', 'anthropic', 200000);
exec add_model('claude-3-haiku-20240307', 'Chat', 'anthropic', 200000);


-- As of Apr 2024 together supports JSON mode for the following models.
update ai_model set json_mode='Y'
 where model_name in (
   'mistralai/Mixtral-8x7B-Instruct-v0.1', 
   'mistralai/Mistral-7B-Instruct-v0.1', 
   'togethercomputer/CodeLlama-34b-Instruct');

exec drop_table('ai_session');
begin
   if not does_table_exist('ai_session') then 
      execute immediate '
      create table ai_session (
      session_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      session_name varchar2(512) not null,
      model_id number not null,
      max_tokens number default null,
      randomness number default null,
      pause number default null,
      total_tokens number default 0 not null,
      elapsed_seconds number default 0,
      call_count number default 0,
      status varchar2(32) default ''active'',
      created timestamp default systimestamp)';
   end if;
   add_primary_key('ai_session', 'session_id');
   if not does_index_exist('ai_session_01') then
      execute immediate 'create index ai_session_01 on ai_session(session_name)';
   end if;
   if not does_constraint_exist('fk_ai_session_model_id') then
      execute immediate 'alter table ai_session add constraint fk_ai_session_model foreign key (model_id) references ai_model(model_id)';
   end if;
end;
/

exec drop_table('ai_session_prompt');
begin
   if not does_table_exist('ai_session_prompt') then 
      execute immediate '
      create table ai_session_prompt (
      session_prompt_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      session_id number not null,
      start_time timestamp default systimestamp,
      end_time timestamp default null,
      elapsed_seconds number default 0,
      finish_reason varchar2(32) default ''n/a'',
      total_tokens number default 0 not null,
      prompt_role varchar2(32) not null,
      prompt clob not null,
      response clob default null,
      response_id varchar2(512) default null,
      schema clob default null,
      tools clob default null,
      function_name varchar2(128) default null,
      -- When 1 will not be included in prompt reconstruction.
      exclude number default 0,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('ai_session_prompt', 'session_prompt_id');
   add_foreign_key('ai_session_prompt', 'session_id', 'ai_session', 'session_id', true);
end;
/

exec drop_table('ai_session_response');

begin
   if not does_table_exist('ai_plugin') then 
      execute immediate '
      create table ai_plugin (
      plugin_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      function_name varchar2(512) not null,
      parm1 varchar2(512) default null,
      parm2 varchar2(512) default null,
      parm3 varchar2(512) default null,
      parm4 varchar2(512) default null,
      parm5 varchar2(512) default null,
      created timestamp default systimestamp,
      status varchar2(32) default ''active'')';
   end if;
end;
/


