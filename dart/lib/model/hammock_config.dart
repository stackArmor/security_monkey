@MirrorsUsed(targets: const [
  Account,
  IgnoreEntry,
  Issue,
  AuditorSetting,
  Item,
  ItemComment,
  NetworkWhitelistEntry,
  Revision,
  RevisionComment,
  UserSetting,
  User,
  Role,
  AccountConfig,
  AccountBulkUpdate,
  AuditScore,
  TechMethods,
  AccountPatternAuditScore,
  WatcherConfig
], override: '*')
import 'dart:mirrors';

import 'package:angular/angular.dart';
import 'package:hammock/hammock.dart';
import 'package:security_monkey/util/constants.dart';

import 'Account.dart';
import 'AccountBulkUpdate.dart';
import 'AccountPatternAuditScore.dart';
import 'GuardDutyEvent.dart';
import 'POAMItem.dart';
import 'charts.dart';
import 'Issue.dart';
import 'Item.dart';
import 'ItemComment.dart';
import 'Revision.dart';
import 'RevisionComment.dart';
import 'Role.dart';
import 'User.dart';
import 'UserSetting.dart';
import 'account_config.dart';
import 'auditorsetting.dart';
import 'auditscore.dart';
import 'ignore_entry.dart';
import 'network_whitelist_entry.dart';
import 'techmethods.dart';
import 'watcher_config.dart';
import 'AnchoreConfigItem.dart';

Resource serializeAccount(Account account) =>
    resource("accounts", account.id, account.toJson());

Resource serializeAccountBulkUpdate(AccountBulkUpdate bulk_update) =>
    resource("accounts_bulk", "batch", bulk_update.toJson());

Resource serializeAnchore(AnchoreConfigItem image) => resource("anchoreconfig", image.id, {
      "id":image.id,
      "name": image.name,
      "username": image.username,
      "password": image.password,
      "url": image.url,
      "ssl_verify": image.ssl_verify
    });


final serializeIssue = serializer("issues", [
  "id",
  "score",
  "issue",
  "notes",
  "justified",
  "justified_user",
  "justification",
  "justified_date",
  "item_id"
]);
final serializeRevision = serializer("revisions",
    ["id", "item_id", "config", "active", "date_created", "diff_html"]);
final serializeItem =
    serializer("items", ["id", "technology", "region", "account", "name"]);
final serializeRevisionComment = serializer("comments", ["text"]);
final serializeItemComment = serializer("comments", ["text"]);
final serializeUserSetting = serializer(
    "settings", ["daily_audit_email", "change_report_setting", "accounts"]);
final serializeNetworkWhitelistEntry =
    serializer("whitelistcidrs", ["id", "name", "notes", "cidr"]);
final serializeUser = serializer("users", ["id", "email", "active", "role_id"]);
final serializeRole = serializer("roles", ["id"]);
final serializeIgnoreListEntry =
    serializer("ignorelistentries", ["id", "prefix", "notes", "technology"]);
final serializeAuditorSettingEntry = serializer("auditorsettings",
    ["account", "technology", "issue", "count", "disabled", "id"]);
final serializeAuditScore = serializer(
    "auditscores", ["id", "method", "score", "technology", "disabled"]);
final serializeAccountPatternAuditScore =
    serializer("accountpatternauditscores", [
  "id",
  "account_type",
  "account_field",
  "account_pattern",
  "score",
  "itemauditscores_id"
]);
final serializeWatcherConfig = serializer(
    "watcher_config", ["index", "interval", "active", "remove_items"]);
final serializeWorldMapGuardDutyData = serializer("worldmapguarddutydata", [
  "lat",
  "lon",
  "count",
  "cityName",
  "countryName",
  "localPort",
  "localPortName",
  "remoteIpV4",
  "remoteOrg",
  "remoteOrgASN",
  "remoteOrgASNOrg",
  "remoteOrgISP"
]);
final serializeTop10CountriesGaurdDutyData =
    serializer("top10countryguarddutydata", ["count", "countryName"]);
final serializeVulnByTech =
    serializer("vulnbytech", ["technology", "count", "percentage"]);
final serializeVulnBySeverity =
    serializer("vulnbyseverity", ["low", "medium", "high"]);
final serializePOAMItem = serializer("poamitems", [
  "poam_id",
  "item_id",
  "account",
  "score",
  "control",
  "weakness_name",
  "weakness_description",
  "poam_comments",
  "create_date"
]);

createHammockConfig(Injector inj) {
  return new HammockConfig(inj)
    ..set({
      "whitelistcidrs": {
        "type": NetworkWhitelistEntry,
        "serializer": serializeNetworkWhitelistEntry,
        "deserializer": {"query": deserializeNetworkWhitelistEntry}
      },
      "ignorelistentries": {
        "type": IgnoreEntry,
        "serializer": serializeIgnoreListEntry,
        "deserializer": {"query": deserializeIgnoreListEntry}
      },
      "auditscores": {
        "type": AuditScore,
        "serializer": serializeAuditScore,
        "deserializer": {"query": deserializeAuditScore}
      },
      "techmethods": {
        "type": TechMethods,
        "deserializer": {"query": deserializeTechMethods}
      },
      "auditorsettings": {
        "type": AuditorSetting,
        "serializer": serializeAuditorSettingEntry,
        "deserializer": {"query": deserializeAuditorSettingEntry}
      },
      "accounts": {
        "type": Account,
        "serializer": serializeAccount,
        "deserializer": {"query": deserializeAccount}
      },
      "account_config": {
        "type": AccountConfig,
        "deserializer": {"query": deserializeAccountConfig}
      },
      "issues": {
        "type": Issue,
        "serializer": serializeIssue,
        "deserializer": {"query": deserializeIssue}
      },
      "revisions": {
        "type": Revision,
        "serializer": serializeRevision,
        "deserializer": {"query": deserializeRevision}
      },
      "revision_comments": {
        "type": RevisionComment,
        "serializer": serializeRevisionComment,
        "deserializer": {"query": deserializeRevisionComment}
      },
      "items": {
        "type": Item,
        "serializer": serializeItem,
        "deserializer": {"query": deserializeItem}
      },
      "item_comments": {
        "type": ItemComment,
        "serializer": serializeItemComment,
        "deserializer": {"query": deserializeItemComment}
      },
      "settings": {
        "type": UserSetting,
        "serializer": serializeUserSetting,
        "deserializer": {"query": deserializeUserSetting}
      },
      "users": {
        "type": User,
        "serializer": serializeUser,
        "deserializer": {"query": deserializeUser}
      },
      "roles": {
        "type": Role,
        "serializer": serializeRole,
        "deserializer": {"query": deserializeRole}
      },
      "account_bulk_update": {
        "type": AccountBulkUpdate,
        "serializer": serializeAccountBulkUpdate
      },
      "accountpatternauditscores": {
        "type": AccountPatternAuditScore,
        "serializer": serializeAccountPatternAuditScore,
        "deserializer": {"query": deserializeAccountPatternAuditScore}
      },
      "watcher_config": {
        "type": WatcherConfig,
        "serializer": serializeWatcherConfig,
        "deserializer": {"query": deserializeWatcherConfig}
      },
      "worldmapguarddutydata": {
        "type": WorldMapGuardDutyData,
        "serializer": serializeWorldMapGuardDutyData,
        "deserializer": {"query": deserializeWorldMapGuardDutyData}
      },
      "top10countryguarddutydata": {
        "type": Top10CountriesGaurdDutyData,
        "serializer": serializeTop10CountriesGaurdDutyData,
        "deserializer": {"query": deserializeTop10CountriesGaurdDutyData}
      },
      "vulnbytech": {
        "type": VulnByTech,
        "serializer": serializeVulnByTech,
        "deserializer": {"query": deserializeVulnByTech}
      },
      "vulnbyseverity": {
        "type": VulnBySeverity,
        "serializer": serializeVulnBySeverity,
        "deserializer": {"query": deserializeVulnBySeverity}
      },
      "poamitems": {
        "type": POAMItem,
        "serializer": serializePOAMItem,
        "deserializer": {"query": deserializePOAMItem}
      },
      "anchoreconfig": {
        "type": AnchoreConfigItem,
        "serializer": serializeAnchore,
        "deserializer": {"query": deserializeAnchore}
      }
    })
    ..urlRewriter.baseUrl = '$API_HOST'
    ..requestDefaults.withCredentials = true
    ..requestDefaults.xsrfCookieName = 'XSRF-COOKIE'
    ..requestDefaults.xsrfHeaderName = 'X-CSRFToken'
    ..documentFormat = new JsonApiOrgFormat();
}

serializer(type, attrs) {
  return (obj) {
    final m = reflect(obj);

    final id = m.getField(#id).reflectee;
    final content = attrs.fold({}, (res, attr) {
      res[attr] = m.getField(new Symbol(attr)).reflectee;
      return res;
    });

    return resource(type, id, content);
  };
}

deserializeAnchore(r) => new AnchoreConfigItem.fromMap(r.content);

deserializeAccount(r) => new Account.fromMap(r.content);

deserializeAccountConfig(r) => new AccountConfig.fromMap(r.content);

deserializeIssue(r) => new Issue.fromMap(r.content);

deserializeRevision(r) => new Revision.fromMap(r.content);

deserializeItem(r) => new Item.fromMap(r.content);

deserializeRevisionComment(r) => new RevisionComment.fromMap(r.content);

deserializeItemComment(r) => new ItemComment.fromMap(r.content);

deserializeUserSetting(r) => new UserSetting.fromMap(r.content);

deserializeNetworkWhitelistEntry(r) =>
    new NetworkWhitelistEntry.fromMap(r.content);

deserializeIgnoreListEntry(r) => new IgnoreEntry.fromMap(r.content);

deserializeAuditorSettingEntry(r) => new AuditorSetting.fromMap(r.content);

deserializeAuditScore(r) => new AuditScore.fromMap(r.content);

deserializeTechMethods(r) => new TechMethods.fromMap(r.content);

deserializeUser(r) => new User.fromMap(r.content);

deserializeRole(r) => new Role.fromMap(r.content);

deserializeAccountPatternAuditScore(r) =>
    new AccountPatternAuditScore.fromMap(r.content);

deserializeWatcherConfig(r) => new WatcherConfig.fromMap(r.content);

deserializeWorldMapGuardDutyData(r) =>
    new WorldMapGuardDutyData.fromMap(r.content);

deserializeTop10CountriesGaurdDutyData(r) =>
    new Top10CountriesGaurdDutyData.fromMap(r.content);

deserializeVulnByTech(r) => new VulnByTech.fromMap(r.content);

deserializeVulnBySeverity(r) => new VulnBySeverity.fromMap(r.content);

deserializePOAMItem(r) => new POAMItem.fromMap(r.content);

class JsonApiOrgFormat extends JsonDocumentFormat {
  resourceToJson(Resource res) {
    return res.content;
  }

  Resource jsonToResource(type, json) {
    return resource(type, json["id"], json);
  }

  QueryResult<Resource> jsonToManyResources(type, json) {
    Map pagination = {};
    for (var key in json.keys) {
      if (key != 'items') {
        pagination[key] = json[key];
      }
    }

    if (json.containsKey('items')) {
      json[type] = json['items'];
    }
    return new QueryResult(
        json[type].map((r) => resource(type, r["id"], r)).toList(), pagination);
  }
}
