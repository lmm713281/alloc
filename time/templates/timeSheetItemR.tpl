<form action="{$url_alloc_timeSheetItem}" method="post">
<table width="100%" cellspacing="0" border="0" class="{$timeSheetItem_class}">
<tr>
  <td valign="top" class="nobr" width="10%">{$timeSheetItem_dateTimeSheetItem}</td>
  <td valign="top" width="30%">{$timeSheetItem_timeSheetItemDuration} {$unit} @ {page::money($timeSheet_currencyTypeID,$timeSheetItem_rate,"%s%m")} x {$timeSheetItem_multiplier}</td>
  <td valign="top" width="10%"><b>{page::money($timeSheet_currencyTypeID,$timeSheetItem_unit_times_rate,"%s%m")}</b></td>
  <td valign="top">{$timeSheetItem_taskID} {$timeSheetItem_description}{$timeSheetItem_comment}</td>
  <td valign="top" align="right">{$timeSheetItem_status}<nobr>{$timeSheetItem_buttons}</nobr></td>
</tr>
</table>
<input type="hidden" name="timeSheetItem_timeSheetItemID" value="{$timeSheetItem_timeSheetItemID}">
<input type="hidden" name="timeSheetID" value="{$timeSheetItem_timeSheetID}">
</form>

