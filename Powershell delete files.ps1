 $items=gci C:\deletetest
 foreach ($item in $items) {if ($Item.lastwritetime -lt (get-date).adddays(-7)){remove-item $item.fullname}}