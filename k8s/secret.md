echo "username1" > ./username.txt
echo "password1" > ./password.txt
echo "username2" > ./username2.txt
echo "ePasswords2" > ./password2.txt

kubectl create secret generic db-user-pass \
  --from-file=username=./username.txt \
  --from-file=password=./password.txt \
  --from-file=username2=./username2.txt \
  --from-file=password2=./password2.txt

kubectl get secret db-user-pass -o jsonpath='{.data.password}' | base64 --decode
