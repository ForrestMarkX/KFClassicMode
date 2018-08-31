Class ClassicCharDataInfo extends Object
	config(Game)
	perobjectconfig
	DependsOn(ClassicPlayerReplicationInfo);

var config byte HeadMeshIndex,HeadSkinIndex,BodyMeshIndex,BodySkinIndex,AttachmentMesh0,AttachmentSkin0,AttachmentMesh1,AttachmentSkin1,AttachmentMesh2,AttachmentSkin2,HasInit;

final function FMyCustomChar LoadData()
{
	local FMyCustomChar R;
	
	if( HasInit<2 )
	{
		AttachmentMesh0 = 255;
		AttachmentSkin0 = 255;
		AttachmentMesh1 = 255;
		AttachmentSkin1 = 255;
		AttachmentMesh2 = 255;
		AttachmentSkin2 = 255;
		HeadMeshIndex = 255;
		HeadSkinIndex = 255;
		BodyMeshIndex = 255;
		BodySkinIndex = 255;
	}
	R.HeadMeshIndex = HeadMeshIndex;
	R.HeadSkinIndex = HeadSkinIndex;
	R.BodyMeshIndex = BodyMeshIndex;
	R.BodySkinIndex = BodySkinIndex;
	R.AttachmentMeshIndices[0] = AttachmentMesh0;
	R.AttachmentSkinIndices[0] = AttachmentSkin0;
	R.AttachmentMeshIndices[1] = AttachmentMesh1;
	R.AttachmentSkinIndices[1] = AttachmentSkin1;
	R.AttachmentMeshIndices[2] = AttachmentMesh2;
	R.AttachmentSkinIndices[2] = AttachmentSkin2;
	return R;
}
final function SaveData( FMyCustomChar R )
{
	HeadMeshIndex = R.HeadMeshIndex;
	HeadSkinIndex = R.HeadSkinIndex;
	BodyMeshIndex = R.BodyMeshIndex;
	BodySkinIndex = R.BodySkinIndex;
	AttachmentMesh0 = R.AttachmentMeshIndices[0];
	AttachmentSkin0 = R.AttachmentSkinIndices[0];
	AttachmentMesh1 = R.AttachmentMeshIndices[1];
	AttachmentSkin1 = R.AttachmentSkinIndices[1];
	AttachmentMesh2 = R.AttachmentMeshIndices[2];
	AttachmentSkin2 = R.AttachmentSkinIndices[2];
	HasInit = 2;
	SaveConfig();
}

defaultproperties
{
}